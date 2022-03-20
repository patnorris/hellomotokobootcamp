// http://www.learningaboutelectronics.com/Articles/How-to-create-a-dynamic-HTML-list-with-Javascript.php
// https://stackoverflow.com/questions/7677028/how-can-i-dynamically-create-an-unordered-list-in-javascript

import { hello, canisterId, createActor } from "../../../../declarations/hello";

import { AuthClient } from "@dfinity/auth-client";
import { html, render } from "lit-html";
//import { AuthClient } from "../../../node_modules/@dfinity/auth-client";
//import { html, render } from "../../../node_modules/lit-html";

const notLoggedInContent = html`<div class="container">
  <h2>You are not authenticated</h2>
  <p>To log in, click this button!</p>
  <button type="button" id="loginButton">Log in</button>
</div>`;

export const renderIndex = async () => {
  console.log('in usercollection renderIndex');
  render(notLoggedInContent, document.getElementById("login"));
};

const loggedInContent = () => html`<div class="container">
  <style>
    #whoami {
      border: 1px solid #1a1a1a;
      margin-bottom: 1rem;
    }
  </style>
  <h1>Internet Identity Client</h1>
  <h2>You are authenticated!</h2>
  <p>To see how a canister views you, click this button!</p>
  <button type="button" id="whoamiButton" class="primary">Who am I?</button>
  <input type="text" readonly id="whoami" placeholder="your Identity" />
  <button id="logout">log out</button>
</div>`;

export const renderLoggedIn = async (actor, authClient) => {
  console.log('in allnfts renderLoggedIn actor');
  console.log(actor);
  console.log('in allnfts renderLoggedIn authClient');
  console.log(authClient);
  //const identity = await authClient.getIdentity();
  (document.getElementById("logout")).onclick =
    async () => {
      await authClient.logout();
      renderIndex();
    };
  const allNftsResponse = await actor.totalSupply();
  console.log('in allnfts renderLoggedIn allNftsResponse');
  console.log(allNftsResponse);
  var allNftList= document.getElementById("allnfts");

  var totalSupply = document.createElement("section");
  totalSupply.innerText = allNftsResponse;

  var nft = document.createElement("li");
  //nft.appendChild(totalSupply);
  //allNftList.appendChild(nft);
};

async function handleAuthenticated(authClient) {
  console.log('in allnfts handleAuthenticated authClient');
  console.log(authClient);
  const identity = await authClient.getIdentity();
  console.log('in allnfts handleAuthenticated identity');
  console.log(identity);
  const nft_actor = createActor(canisterId, {
    agentOptions: {
      identity,
    },
  });
  console.log('in allnfts handleAuthenticated nft_actor');
  console.log(nft_actor);
  renderLoggedIn(nft_actor, authClient);
}

const init = async () => {
  console.log('in allnfts init');
  const authClient = await AuthClient.create();
  console.log('in allnfts init authClient');
  console.log(authClient);
  if (await authClient.isAuthenticated()) {
    handleAuthenticated(authClient);
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
        handleAuthenticated(authClient);
      },
      identityProvider:
        process.env.DFX_NETWORK === "ic"
          ? "https://identity.ic0.app/#authorize"
          : process.env.LOCAL_II_CANISTER,
      // Maximum authorization expiration is 8 days
      maxTimeToLive: days * hours * nanoseconds,
    });
  };
}

init();

// check if helpful for storing pictures: https://github.com/deckgo/deckdeckgo/tree/main/canisters/src
// word-based for now (in mint, randomly assign values for Genre, actor 1, actor 2, setting, city, IC NFT collection)
// generate movie poster with: https://colab.research.google.com/github/dribnet/clipit/blob/master/demos/PixelDrawer.ipynb#scrollTo=XziodsCqVC2A
// https://github.com/jorgenbuilder/token-standards-lecture
// 31: https://github.com/jorgenbuilder/diamond-giraffe-peanut

// fun token integration: provide as param in mint func, if above threshold rare attribute Budget is added