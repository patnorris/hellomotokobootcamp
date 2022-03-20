import Result "mo:base/Result";

import Metadata "metadata";
import NftError "errors";

module {
    // ###################### copied into main.mo ################
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

    public query func getProperties() : async [NFTProperty] {
        return [#MovieGenre, #MovieTitle, #MovieSubtitle, #DfinityActor, #ICEcosystemActor, #MotokoBootcampActor, #PresentedBy, #BudgetCategory, #MusicArtist];
        // ugly but how to iterate variant type?
    };

    stable let movieGenres : [Text] = ["Action", "Comedy", "Fantasy/Sci-fi", "Romance", "Musical"];
    stable let movieTitles : [Text] = ["Crypto Rodeo", "Lord of the Chains", "All Hail the Blockchain Singularity", "Hidden Symbols and Rituals of the 8-Year-Gang", "Big Tech Wars"];
    stable let movieSubtitles : [Text] = ["Wen?", "LFG!!!", "Mom, I want to be a Cryptographer", "To Dfinity and Beyond", "The Community Has Spoken"];
    stable let dfinityActors : [Text] = ["Dominic Williams", "Elizabeth Yang", "Kyle Peacock", "Andreas Rossberg", "Lara Schmid"];
    stable let icEcosystemActors : [Text] = ["Motoko", "Poked Bot", "ICPunk", "Ludo", "Psychedelic DAO"];
    stable let motokoBootcampActors : [Text] = ["Isaac Valadez", "Sebastien Thuillier", "Dukakis Tejada", "Motoko Beginner", "Motoko Intermediate"];
    stable let presentedBy : [Text] = ["Dfinity", "Internet Computer Association", "Toniq Labs", "Fleek", "DSCVR"];
    stable let budgetCategories : [Text] = ["Blockbuster", "Major", "Independent", "B-List", "Student Project (at most)"];
    stable let musicArtists : [Text] = ["Hans Zimmer", "Snoop Dogg & Dr. Dre", "The Jackson 5", "Motley Crue", "Daft Punk"];

    public query func getNFTPropertyValue (property : NFTProperty, number : Nat) : async (Text, Metadata.GenericValue) {
        var attributeNumber = number;
        if (number > 4) { // Limitation
            attributeNumber := 4;
        };
        switch(property) {
			case (#MovieGenre) {
                let assignedGenre : text = movieGenres[number];
                return ("Genre", #TextContent assignedGenre); 
            };
            case (#MovieTitle) { 
                let assignedTitle : text = movieTitles[number];
                return ("Title", #TextContent assignedTitle); 
            };
            case (#MovieSubtitle) { 
                let assignedSubtitle : text = movieSubtitles[number];
                return ("Subtitle", #TextContent assignedSubtitle); 
            };
            case (#DfinityActor) { 
                let assignedCoActor : text = dfinityActors[number];
                return ("CoActor", #TextContent assignedCoActor); 
            };
            case (#ICEcosystemActor) {
                let assignedSupportActor : text = icEcosystemActors[number];
                return ("SupportActor", #TextContent assignedSupportActor); 
            };
            case (#MotokoBootcampActor) { 
                let assignedLeadActor : text = motokoBootcampActors[number];
                return ("LeadActor", #TextContent assignedLeadActor); 
            };
            case (#PresentedBy) { 
                let assignedPresentedBy : text = presentedBy[number];
                return ("PresentedBy", #TextContent assignedPresentedBy); 
            };
            case (#BudgetCategory) { 
                let assignedBudget : text = budgetCategories[number];
                return ("Budget", #TextContent assignedBudget); 
            };
            case (#MusicArtist) { 
                let assignedMusic : text = musicArtists[number];
                return ("Music", #TextContent assignedMusic); 
            };
			case _ {
				return (#Other "Special");
			};
		}
    };
}