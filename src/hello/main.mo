import Error "mo:base/Error";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import P "mo:base/Prelude";
import Int "mo:base/Int";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Result "mo:base/Result";
import Time "mo:base/Time";
import Random "mo:base/Random";
import Blob "mo:base/Blob";

import NftError "errors";
import Metadata "metadata";

actor {
  public func greet(name : Text) : async Text {
    return "Hello, " # name # "! See you at Motoko Bootcamp.";
  };

// ################ State ###################
	
	stable var name_ : Text = "IC Movies NFT";
	
	stable var symbol_ : Text = "MOVe";
	
	// Adapted from: https://github.com/SuddenlyHazel/DIP721/blob/main/src/DIP721/DIP721.mo
	// and https://github.com/jorgenbuilder/token-standards-lecture 
	
	private type TokenAddress = Principal;
	private type TokenId = Nat;
	
	private stable var tokenPk : Nat = 0;
	
	private stable var tokenURIEntries : [(TokenId, Text)] = [];
	private stable var ownersEntries : [(TokenId, Principal)] = [];
	private stable var balancesEntries : [(Principal, Nat)] = [];
	private stable var tokenApprovalsEntries : [(TokenId, Principal)] = [];
	private stable var operatorApprovalsEntries : [(Principal, [Principal])] = [];
	
	private let tokenURIs : HashMap.HashMap<TokenId, Text> = HashMap.fromIter<TokenId, Text>(tokenURIEntries.vals(), 10, Nat.equal, Hash.hash);
	private let owners : HashMap.HashMap<TokenId, Principal> = HashMap.fromIter<TokenId, Principal>(ownersEntries.vals(), 10, Nat.equal, Hash.hash);
	private let balances : HashMap.HashMap<Principal, Nat> = HashMap.fromIter<Principal, Nat>(balancesEntries.vals(), 10, Principal.equal, Principal.hash);
	private let tokenApprovals : HashMap.HashMap<TokenId, Principal> = HashMap.fromIter<TokenId, Principal>(tokenApprovalsEntries.vals(), 10, Nat.equal, Hash.hash);
	private let operatorApprovals : HashMap.HashMap<Principal, [Principal]> = HashMap.fromIter<Principal, [Principal]>(operatorApprovalsEntries.vals(), 10, Principal.equal, Principal.hash);
	
	stable var ledger : [var Metadata.TokenMetadata] = [var];

// ####################### Query Methods ######################

    // @DIP721: () -> (nat) query;
    public query func totalSupply () : async Nat {
        ledger.size();
    };

	private func _unwrap<T>(x : ?T) : T {
		switch x {
			case null { P.unreachable() };
			case (?x_) { x_ };
		}
	};

	public shared query (doIOwn__msg) func doIOwn(tokenId : Nat) : async Bool {
		let caller = doIOwn__msg.caller; // First input
		_ownerOf(tokenId) == ?caller;
	};
	
    // @DIP721: (user: principal) -> (nat64) query;
    public query func balanceOf (
        user : Principal,
    ) : async Nat {
        Array.filter<Metadata.TokenMetadata>(Array.freeze(ledger), func (t) {
            t.owner == user
        }).size();
    };
	
	// @DIP721: (tokenId: nat) -> (variant { ok = opt Principal; err = NftError }) query;
    public query func ownerOf (
        tokenId : Nat,
    ) : async Result.Result<?Principal, NftError.NftError> {
        if (tokenId < ledger.size()) {
            #ok(?ledger[tokenId].owner);
        } else {
            #err(#TokenNotFound);
        };
    };

	// @DIP721: (tokenId: nat) -> (variant { ok = TokenMetadata; err = NftError }) query;
    public query func tokenMetadata (
        tokenId : Nat,
    ) : async Result.Result<Metadata.TokenMetadata, NftError.NftError> {
        if (tokenId < ledger.size()) {
            #ok(ledger[tokenId]);
        } else {
            #err(#TokenNotFound);
        };
    };

	// @DIP721: (user: principal) -> (variant { ok = vec TokenMetadata; err = NftError }) query;
    public query func ownerTokenMetadata (
        user : Principal,
    ) : async Result.Result<[Metadata.TokenMetadata], NftError.NftError> {
       #ok(
            Array.filter<Metadata.TokenMetadata>(Array.freeze(ledger), func (t) {
                t.owner == user
            })
       );
    };

	public query ({ caller }) func callerTokenMetadata () : async Result.Result<[Metadata.TokenMetadata], NftError.NftError> {
       #ok(
            Array.filter<Metadata.TokenMetadata>(Array.freeze(ledger), func (t) {
                t.owner == caller
            })
       );
    };

	public query ({ caller }) func allTokenMetadata () : async Result.Result<[Metadata.TokenMetadata], NftError.NftError> {
       #ok(
            Array.freeze(ledger)
       );
    };
	
	public shared query func name() : async Text {
		return "IC Movies NFT";
	};
	
	public shared query func symbol() : async Text {
		return symbol_;
	};

	// @DIP721: () -> (opt text) query;
    public query func logo () : async ?Text {
        ?"https://www.dfinitycommunity.com/content/images/2021/12/5-reasons-why-IC-matters-1.jpg";
    };

// ##################### NFT Details #################
	public type NFTProperty = {
        #MovieGenre           : Text;
        #MovieTitle           : Text;
        #MovieSubtitle        : Text;
        #DfinityActor         : Text;
        #ICEcosystemActor     : Text;
        #MotokoBootcampActor  : Text;
        #PresentedBy          : Text;
        #BudgetCategory       : Text;
        #MusicArtist          : Text; 
        #Other                : Text;        
    };

    stable let nftProperties : [NFTProperty] = [#MovieGenre "MovieGenre", #MovieTitle "MovieTitle", #MovieSubtitle "MovieSubtitle", #DfinityActor "DfinityActor", #ICEcosystemActor "ICEcosystemActor", #MotokoBootcampActor "MotokoBootcampActor", #PresentedBy "PresentedBy", #MusicArtist "MusicArtist", #BudgetCategory "BudgetCategory"]; // ugly but how to iterate variant type?

    stable let movieGenres : [Text] = ["Action", "Comedy", "Fantasy/Sci-fi", "Romance", "Musical"];
    stable let movieTitles : [Text] = ["Crypto Rodeo", "Lord of the Chains", "All Hail the Blockchain Singularity", "Hidden Symbols and Rituals of the 8-Year-Gang", "Big Tech Wars"];
    stable let movieSubtitles : [Text] = ["Wen?", "LFG!!!", "Mom, I want to be a Cryptographer", "To Dfinity and Beyond", "The Community Has Spoken"];
    stable let dfinityActors : [Text] = ["Dominic Williams", "Elizabeth Yang", "Kyle Peacock", "Andreas Rossberg", "Lara Schmid"];
    stable let icEcosystemActors : [Text] = ["Motoko", "Poked Bot", "ICPunk", "Ludo", "Psychedelic DAO"];
    stable let motokoBootcampActors : [Text] = ["Isaac Valadez", "Sebastien Thuillier", "Dukakis Tejada", "Motoko Beginner", "Motoko Intermediate"];
    stable let presentedBy : [Text] = ["Dfinity", "Internet Computer Association", "Toniq Labs", "Fleek", "DSCVR"];
    stable let budgetCategories : [Text] = ["Blockbuster", "Major", "Independent", "B-List", "Student Project (at most)"];
    stable let musicArtists : [Text] = ["Hans Zimmer", "Snoop Dogg & Dr. Dre", "The Jackson 5", "Motley Crue", "Daft Punk"];

    private func getNFTPropertyValue(property : NFTProperty, number : Nat) : ((Text, Metadata.GenericValue)) {
        var attributeNumber = 0;
		if (number > 4) {
			attributeNumber := number - 3;
		} else {
			attributeNumber := number;
		};
        switch(property) {
			case (#MovieGenre "MovieGenre") {
                let assignedGenre : Text = movieGenres[attributeNumber];
                return ("Genre", #TextContent assignedGenre); 
            };
            case (#MovieTitle "MovieTitle") { 
                let assignedTitle : Text = movieTitles[attributeNumber];
                return ("Title", #TextContent assignedTitle); 
            };
            case (#MovieSubtitle "MovieSubtitle") { 
                let assignedSubtitle : Text = movieSubtitles[attributeNumber];
                return ("Subtitle", #TextContent assignedSubtitle); 
            };
            case (#DfinityActor "DfinityActor") { 
                let assignedCoActor : Text = dfinityActors[attributeNumber];
                return ("CoActor", #TextContent assignedCoActor); 
            };
            case (#ICEcosystemActor "ICEcosystemActor") {
                let assignedSupportActor : Text = icEcosystemActors[attributeNumber];
                return ("SupportActor", #TextContent assignedSupportActor); 
            };
            case (#MotokoBootcampActor "MotokoBootcampActor") { 
                let assignedLeadActor : Text = motokoBootcampActors[attributeNumber];
                return ("LeadActor", #TextContent assignedLeadActor); 
            };
            case (#PresentedBy "PresentedBy") { 
                let assignedPresentedBy : Text = presentedBy[attributeNumber];
                return ("PresentedBy", #TextContent assignedPresentedBy); 
            };
            case (#BudgetCategory "BudgetCategory") { 
                let assignedBudget : Text = budgetCategories[attributeNumber];
                return ("Budget", #TextContent assignedBudget); 
            };
            case (#MusicArtist "MusicArtist") { 
                let assignedMusic : Text = musicArtists[attributeNumber];
                return ("Music", #TextContent assignedMusic); 
            };
			case _ {
				return ("Other", #TextContent "Special");
			};
		}
    };

// ############## Update Methods ####################
    func bit(b : ?Nat) : Nat {
        switch(b) {
            case null 0;
            case (?nat) {
				if (nat > 4) {
					return nat - 3;
				} else {
					return nat;
				}
			}
        };
    };

	var randomNumbers : [var Nat] = Array.init(nftProperties.size(), 0);
    func generateRandomProperty(i: Nat) : ((Text, Metadata.GenericValue)) {
		let randomProperty = getNFTPropertyValue(nftProperties[i], randomNumbers[i]);
		return randomProperty;
	};

	// @DIP721: (principal, nat64, vec record { text; GenericValue }) -> (variant { Ok : nat; Err : NftError })
    public shared ({ caller }) func mint (
        // to          : Principal,
        // tokenId     : Nat,
        // properties  : [(Text, Metadata.GenericValue)],
    ) : async Nat {
		if (Principal.isAnonymous(caller)) {
			return ledger.size();
		};
		var entropy = Blob.fromArray([0]);
		for (i in Iter.range(0, nftProperties.size() - 1)) {
			entropy := await Random.blob();
			randomNumbers[i] := bit(Random.Finite(entropy).range(3));                     
      	};
		// use tokenPk as increasing index (i.e. mint from 0 to n and ignore tokenId param)
        ledger := Array.tabulateVar<Metadata.TokenMetadata>(ledger.size() + 1, func (i) {
            if (i < ledger.size()) {
                ledger[i];
            } else {
				// assign properties randomly
				let randomProperties : [(Text, Metadata.GenericValue)] = Array.tabulate<(Text, Metadata.GenericValue)>(nftProperties.size(), generateRandomProperty);
                {
                    // owner               = to;
					owner               = caller;
                    token_identifier    = i;
                    properties          = randomProperties;
                    minted_at           = Nat64.fromNat(Int.abs(Time.now()));
                    minted_by           = caller;
                    operator            = null;
                    transferred_at      = null;
                    transferred_by      = null;
                };
            }
        });
        // DIP721 expects the returned Nat to be the id of the token
        ledger.size() - 1;
    };

	// @DIP721: (from: principal, to: principal, tokenId: nat) -> (variant { ok = Nat; err = NftError });
    public shared ({ caller }) func transferFrom (
        from    : Principal,
        to      : Principal,
        tokenId : Nat,
    ) : async Result.Result<Nat, NftError.NftError> {
        if (tokenId >= ledger.size()) {
            // If the token id exceeds the size of our ledger, this is an invalid token id for us
            return #err(#TokenNotFound);
        };
        let token = ledger[tokenId];
        if (token.owner != caller) {
            // Only the owner may act upon a token
            return #err(#Unauthorized);
        };
        ledger[tokenId] := {
            // Update the owner of the NFT
            owner               = to;
            // Leave everything else the same
            token_identifier    = token.token_identifier;
            properties          = token.properties;
            minted_at           = token.minted_at;
            minted_by           = token.minted_by;
            operator            = token.operator;
            transferred_at      = token.transferred_at;
            transferred_by      = token.transferred_by;
        };
        // DIP721 expects the Nat returned to be the ID of a transaction history record. However, we will not be implementing this for now.
        #ok(0);
    };
	
	// ################## Internal ##########################
	
	private func _ownerOf(tokenId : TokenId) : ?Principal {
		return owners.get(tokenId);
	};
	
	private func _tokenURI(tokenId : TokenId) : ?Text {
		return tokenURIs.get(tokenId);
	};
	
	private func _isApprovedForAll(owner : Principal, opperator : Principal) : Bool {
		switch (operatorApprovals.get(owner)) {
			case(?whiteList) {
				for (allow in whiteList.vals()) {
					if (allow == opperator) {
						return true;
					};
				};
			};
			case null {return false;};
		};
		return false;
	};
	
	private func _approve(to : Principal, tokenId : Nat) : () {
		tokenApprovals.put(tokenId, to);
	};
	
	private func _removeApprove(tokenId : Nat) : () {
		ignore tokenApprovals.remove(tokenId);
	};
	
	private func _exists(tokenId : Nat) : Bool {
		return Option.isSome(owners.get(tokenId));
	};
	
	private func _getApproved(tokenId : Nat) : ?Principal {
		assert _exists(tokenId) == true;
		switch(tokenApprovals.get(tokenId)) {
			case (?v) { return ?v };
			case null {
				return null;
			};
		}
	};
	
	private func _hasApprovedAndSame(tokenId : Nat, spender : Principal) : Bool {
		switch(_getApproved(tokenId)) {
			case (?v) {
				return v == spender;
			};
			case null { return false }
		}
	};
	
	private func _isApprovedOrOwner(spender : Principal, tokenId : Nat) : Bool {
		assert _exists(tokenId);
		let owner = _unwrap(_ownerOf(tokenId));
		return spender == owner or _hasApprovedAndSame(tokenId, spender) or _isApprovedForAll(owner, spender);
	};
	
	private func _transfer(from : Principal, to : Principal, tokenId : Nat) : () {
		assert _exists(tokenId);
		assert _unwrap(_ownerOf(tokenId)) == from;
		
		// Bug in HashMap https://github.com/dfinity/motoko-base/pull/253/files
		// this will throw unless you patch your file
		_removeApprove(tokenId);
		
		_decrementBalance(from);
		_incrementBalance(to);
		owners.put(tokenId, to);
	};
	
	private func _incrementBalance(address : Principal) {
		switch (balances.get(address)) {
			case (?v) {
				balances.put(address, v + 1);
			};
			case null {
				balances.put(address, 1);
			}
		}
	};
	
	private func _decrementBalance(address : Principal) {
		switch (balances.get(address)) {
			case (?v) {
				balances.put(address, v - 1);
			};
			case null {
				balances.put(address, 0);
			}
		}
	};
	
	private func _mint(to : Principal, tokenId : Nat, uri : Text) : () {
		assert not _exists(tokenId);
		
		_incrementBalance(to);
		owners.put(tokenId, to);
		tokenURIs.put(tokenId,uri)
	};
	
	private func _burn(tokenId : Nat) {
		let owner = _unwrap(_ownerOf(tokenId));
		
		_removeApprove(tokenId);
		_decrementBalance(owner);
		
		ignore owners.remove(tokenId);
	};
	
	system func preupgrade() {
		tokenURIEntries := Iter.toArray(tokenURIs.entries());
		ownersEntries := Iter.toArray(owners.entries());
		balancesEntries := Iter.toArray(balances.entries());
		tokenApprovalsEntries := Iter.toArray(tokenApprovals.entries());
		operatorApprovalsEntries := Iter.toArray(operatorApprovals.entries());
		
	};
	
	system func postupgrade() {
		tokenURIEntries := [];
		ownersEntries := [];
		balancesEntries := [];
		tokenApprovalsEntries := [];
		operatorApprovalsEntries := [];
	};

	/* public shared func isApprovedForAll(owner : Principal, opperator : Principal) : async Bool {
		return _isApprovedForAll(owner, opperator);
	};
	
	public shared(msg) func approve(to : Principal, tokenId : TokenId) : async () {
		switch(_ownerOf(tokenId)) {
			case (?owner) {
				assert to != owner;
				assert msg.caller == owner or _isApprovedForAll(owner, msg.caller);
				_approve(to, tokenId);
			};
			case (null) {
				throw Error.reject("No owner for token")
			};
		}
	};
	
	public shared func getApproved(tokenId : Nat) : async Principal {
		switch(_getApproved(tokenId)) {
			case (?v) { return v };
			case null { throw Error.reject("None approved") }
		}
	};
	
	public shared(msg) func setApprovalForAll(op : Principal, isApproved : Bool) : () {
		assert msg.caller != op;
		
		switch (isApproved) {
			case true {
				switch (operatorApprovals.get(msg.caller)) {
					case (?opList) {
						var array = Array.filter<Principal>(opList,func (p) { p != op });
						array := Array.append<Principal>(array, [op]);
						operatorApprovals.put(msg.caller, array);
					};
					case null {
						operatorApprovals.put(msg.caller, [op]);
					};
				};
			};
			case false {
				switch (operatorApprovals.get(msg.caller)) {
					case (?opList) {
						let array = Array.filter<Principal>(opList, func(p) { p != op });
						operatorApprovals.put(msg.caller, array);
					};
					case null {
						operatorApprovals.put(msg.caller, []);
					};
				};
			};
		};
		
	}; */	
}