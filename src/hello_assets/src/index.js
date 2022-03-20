import { hello, canisterId, createActor } from "../../declarations/hello";

import { AuthClient } from "@dfinity/auth-client";
import { html, render } from "lit-html";

const notLoggedInContent = html`<div class="container">
  <h2>You are not authenticated</h2>
  <p>To log in, click this button!</p>
  <button type="button" id="loginButton">Log in</button>
</div>`;

export const renderIndex = async () => {
  render(notLoggedInContent, document.getElementById("pageContent"));
};

const mintPageContent = html`
  <form action="#">
    <label for="nfturl">Ready to create your IC Movie?</label>
    <button type="submit">Mint Now!</button>
  </form>
  <section id="mintresponse"></section>
  <section id="genre"></section>
  <section id="presentedbyAndLeadactor"></section>
  <section id="titleAndSubtitle"></section>
  <section id="coactorAndSupportactor"></section>
  <section id="music"></section>
  <section id="budget"></section>`;

const userPageContent = html`
  <section>My Collected Movie NFTs</section>
  <ul id="usernfts"></ul>`;

const nftPageContent = html`
  <section>All Movie NFTs</section>
  <ul id="allnftlist"></ul>`;

export const renderLoggedIn = async (actor, authClient) => {
  render(mintPageContent, document.getElementById("pageContent"));
  document.querySelector("form").addEventListener("submit", async (e) => {
    e.preventDefault();
    const button = e.target.querySelector("button");  
    button.setAttribute("disabled", true);
    const tokenId = await actor.mint();
    const mintResponse = await actor.tokenMetadata(tokenId);
    if (mintResponse.err) {
      document.getElementById("mintresponse").innerText = "Minting wasn't successful. Please make sure you're logged in and then try again.";
      return false;    
    }
    const nftProperties = {};
    try {
      mintResponse.ok.properties.map(subarr => { nftProperties[subarr[0]] = Object.values(subarr[1])[0];});
    } catch (err) {
      document.getElementById("mintresponse").innerText = "Minting wasn't successful. Please make sure you're logged in and then try again.";
      return false;
    }
  
    button.removeAttribute("disabled");
  
    document.getElementById("mintresponse").innerText = "Success! This is your new IC Movie NFT:";
    document.getElementById("presentedbyAndLeadactor").innerText = nftProperties.PresentedBy + " presents: " + nftProperties.LeadActor + " in";
    document.getElementById("titleAndSubtitle").innerText = nftProperties.Title + " - " + nftProperties.Subtitle;
    document.getElementById("coactorAndSupportactor").innerText = "with appearances by " + nftProperties.CoActor + " and " + nftProperties.SupportActor;
    document.getElementById("music").innerText = "Soundtrack composed by " + nftProperties.Music;
    document.getElementById("genre").innerText = "Genre: " + nftProperties.Genre;
    document.getElementById("budget").innerText = "Budget: " + nftProperties.Budget;
  
    return false;
  });

  (document.getElementById("logout")).onclick =
    async () => {
      await authClient.logout();
      renderIndex();
    };
};

export const renderUserCollection = async (actor, authClient) => {
  render(userPageContent, document.getElementById("pageContent"));
  const identity = await authClient.getIdentity();
  (document.getElementById("logout")).onclick =
    async () => {
      await authClient.logout();
      renderIndex();
    };
  const userNftsResponse = await actor.callerTokenMetadata();
  var userNftList= document.getElementById("usernfts");
  for (var i = 0; i < userNftsResponse.ok.length; i++) {
    const nftProperties = {};
    userNftsResponse.ok[i].properties.map(subarr => { nftProperties[subarr[0]] = Object.values(subarr[1])[0];});
    var separator = document.createElement("section");
    separator.innerText = `
    #####################################
    ${nftProperties.PresentedBy} presents: ${nftProperties.LeadActor} in
    ${nftProperties.Title} - ${nftProperties.Subtitle}
    with appearances by ${nftProperties.CoActor} and ${nftProperties.SupportActor}
    Soundtrack composed by ${nftProperties.Music}
    Genre: ${nftProperties.Genre}
    Budget: ${nftProperties.Budget}
    #####################################
    `;
    var nft = document.createElement("li");
    nft.appendChild(separator);
    userNftList.appendChild(nft);
  }
};

export const renderAllNFTs = async (actor, authClient) => {
  render(nftPageContent, document.getElementById("pageContent"));
  //const identity = await authClient.getIdentity();
  (document.getElementById("logout")).onclick =
    async () => {
      await authClient.logout();
      renderIndex();
    };
  const totalSupplyResponse = await actor.totalSupply();
  const allNftsResponse = await actor.allTokenMetadata();
  var allNftList = document.getElementById("allnftlist");
  var totalSupply = document.createElement("section");
  totalSupply.innerText = "Total Movies in Collection: " + totalSupplyResponse;
  var nft = document.createElement("li");
  nft.appendChild(totalSupply);
  allNftList.appendChild(nft);

  for (var i = 0; i < allNftsResponse.ok.length; i++) {
    const nftProperties = {};
    allNftsResponse.ok[i].properties.map(subarr => { nftProperties[subarr[0]] = Object.values(subarr[1])[0];});
    var separator = document.createElement("section");
    separator.innerText = `
    #####################################
    ${nftProperties.PresentedBy} presents: ${nftProperties.LeadActor} in
    ${nftProperties.Title} - ${nftProperties.Subtitle}
    with appearances by ${nftProperties.CoActor} and ${nftProperties.SupportActor}
    Soundtrack composed by ${nftProperties.Music}
    Genre: ${nftProperties.Genre}
    Budget: ${nftProperties.Budget}
    Owner Principal: ${allNftsResponse.ok[i].owner.toString()}
    #####################################
    `;
    var nft = document.createElement("li");
    nft.appendChild(separator);
    allNftList.appendChild(nft);
  }
};

async function handleAuthenticated(authClient, page = "index") {
  const identity = await authClient.getIdentity();
  const mint_actor = createActor(canisterId, {
    agentOptions: {
      identity,
    },
  });

  if (page === "index") {
    renderLoggedIn(mint_actor, authClient);
  } else if (page === "usercollection") {
    renderUserCollection(mint_actor, authClient);
  } else if (page === "allnfts") {
    renderAllNFTs(mint_actor, authClient);
  } else {
    renderLoggedIn(mint_actor, authClient);
  }
}

const init = async () => {
  const collectionName = await hello.name();
  document.getElementById("collection").innerText = "Welcome to " + collectionName;
  const authClient = await AuthClient.create();
  if (await authClient.isAuthenticated()) {
    handleAuthenticated(authClient, "index");
  }
  renderIndex();
  const loginButton = document.getElementById(
    "loginButton"
  );

  const days = BigInt(1);
  const hours = BigInt(24);
  const nanoseconds = BigInt(3600000000000);

  loginButton.onclick = async () => {
    await authClient.login({
      onSuccess: async () => {
        handleAuthenticated(authClient, "index");
      },
      identityProvider:
        process.env.DFX_NETWORK === "ic"
          ? "https://identity.ic0.app/#authorize"
          : process.env.LOCAL_II_CANISTER,
      maxTimeToLive: days * hours * nanoseconds,
    });
  };
  (document.getElementById("mint")).onclick =
    async () => {
      await init();
    };
  (document.getElementById("usercollection")).onclick =
    async () => {
      await initUserCollection();
    };
  (document.getElementById("allnfts")).onclick =
    async () => {
      await initAllNFTs();
    };
}

const initUserCollection = async () => {
  const authClient = await AuthClient.create();
  if (await authClient.isAuthenticated()) {
    handleAuthenticated(authClient, "usercollection");
  }
  renderIndex();
  const loginButton = document.getElementById(
    "loginButton"
  );

  const days = BigInt(1);
  const hours = BigInt(24);
  const nanoseconds = BigInt(3600000000000);

  loginButton.onclick = async () => {
    await authClient.login({
      onSuccess: async () => {
        handleAuthenticated(authClient, "usercollection");
      },
      identityProvider:
        process.env.DFX_NETWORK === "ic"
          ? "https://identity.ic0.app/#authorize"
          : process.env.LOCAL_II_CANISTER,
      maxTimeToLive: days * hours * nanoseconds,
    });
  };
  (document.getElementById("mint")).onclick =
    async () => {
      await init();
    };
  (document.getElementById("usercollection")).onclick =
    async () => {
      await initUserCollection();
    };
  (document.getElementById("allnfts")).onclick =
    async () => {
      await initAllNFTs();
    };
}

const initAllNFTs = async () => {
  const authClient = await AuthClient.create();
  if (await authClient.isAuthenticated()) {
    handleAuthenticated(authClient, "allnfts");
  }
  renderIndex();
  const loginButton = document.getElementById(
    "loginButton"
  );

  const days = BigInt(1);
  const hours = BigInt(24);
  const nanoseconds = BigInt(3600000000000);

  loginButton.onclick = async () => {
    await authClient.login({
      onSuccess: async () => {
        handleAuthenticated(authClient, "allnfts");
      },
      identityProvider:
        process.env.DFX_NETWORK === "ic"
          ? "https://identity.ic0.app/#authorize"
          : process.env.LOCAL_II_CANISTER,
      maxTimeToLive: days * hours * nanoseconds,
    });
  };
  (document.getElementById("mint")).onclick =
    async () => {
      await init();
    };
  (document.getElementById("usercollection")).onclick =
    async () => {
      await initUserCollection();
    };
  (document.getElementById("allnfts")).onclick =
    async () => {
      await initAllNFTs();
    };
}

init();

// Future enhancements:

// fun token integration: provide as param in mint func, if above threshold rare attribute Budget is added
// pay with tokens to access movies you don't own on all nfts page
// generate movie poster with: https://colab.research.google.com/github/dribnet/clipit/blob/master/demos/PixelDrawer.ipynb#scrollTo=XziodsCqVC2A
// check if helpful for storing pictures: https://github.com/deckgo/deckdeckgo/tree/main/canisters/src
