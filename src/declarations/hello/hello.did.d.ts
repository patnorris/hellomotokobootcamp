import type { Principal } from '@dfinity/principal';
export type GenericValue = { 'Nat64Content' : bigint } |
  { 'Nat32Content' : number } |
  { 'BoolContent' : boolean } |
  { 'Nat8Content' : number } |
  { 'Int64Content' : bigint } |
  { 'IntContent' : bigint } |
  { 'NatContent' : bigint } |
  { 'Nat16Content' : number } |
  { 'Int32Content' : number } |
  { 'Int8Content' : number } |
  { 'Int16Content' : number } |
  { 'BlobContent' : Array<number> } |
  { 'Principal' : Principal } |
  { 'TextContent' : string };
export type NftError = { 'SelfTransfer' : null } |
  { 'TokenNotFound' : null } |
  { 'TxNotFound' : null } |
  { 'SelfApprove' : null } |
  { 'OperatorNotFound' : null } |
  { 'Unauthorized' : null } |
  { 'ExistedNFT' : null } |
  { 'OwnerNotFound' : null } |
  { 'Other' : string };
export type Result = { 'ok' : bigint } |
  { 'err' : NftError };
export type Result_1 = { 'ok' : TokenMetadata } |
  { 'err' : NftError };
export type Result_2 = { 'ok' : Array<TokenMetadata> } |
  { 'err' : NftError };
export type Result_3 = { 'ok' : [] | [Principal] } |
  { 'err' : NftError };
export interface TokenMetadata {
  'transferred_at' : [] | [bigint],
  'transferred_by' : [] | [Principal],
  'owner' : Principal,
  'operator' : [] | [Principal],
  'properties' : Array<[string, GenericValue]>,
  'token_identifier' : bigint,
  'minted_at' : bigint,
  'minted_by' : Principal,
}
export interface _SERVICE {
  'allTokenMetadata' : () => Promise<Result_2>,
  'balanceOf' : (arg_0: Principal) => Promise<bigint>,
  'callerTokenMetadata' : () => Promise<Result_2>,
  'doIOwn' : (arg_0: bigint) => Promise<boolean>,
  'greet' : (arg_0: string) => Promise<string>,
  'logo' : () => Promise<[] | [string]>,
  'mint' : () => Promise<bigint>,
  'name' : () => Promise<string>,
  'ownerOf' : (arg_0: bigint) => Promise<Result_3>,
  'ownerTokenMetadata' : (arg_0: Principal) => Promise<Result_2>,
  'symbol' : () => Promise<string>,
  'tokenMetadata' : (arg_0: bigint) => Promise<Result_1>,
  'totalSupply' : () => Promise<bigint>,
  'transferFrom' : (
      arg_0: Principal,
      arg_1: Principal,
      arg_2: bigint,
    ) => Promise<Result>,
}
