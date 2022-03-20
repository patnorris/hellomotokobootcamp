export const idlFactory = ({ IDL }) => {
  const GenericValue = IDL.Variant({
    'Nat64Content' : IDL.Nat64,
    'Nat32Content' : IDL.Nat32,
    'BoolContent' : IDL.Bool,
    'Nat8Content' : IDL.Nat8,
    'Int64Content' : IDL.Int64,
    'IntContent' : IDL.Int,
    'NatContent' : IDL.Nat,
    'Nat16Content' : IDL.Nat16,
    'Int32Content' : IDL.Int32,
    'Int8Content' : IDL.Int8,
    'Int16Content' : IDL.Int16,
    'BlobContent' : IDL.Vec(IDL.Nat8),
    'Principal' : IDL.Principal,
    'TextContent' : IDL.Text,
  });
  const TokenMetadata = IDL.Record({
    'transferred_at' : IDL.Opt(IDL.Nat64),
    'transferred_by' : IDL.Opt(IDL.Principal),
    'owner' : IDL.Principal,
    'operator' : IDL.Opt(IDL.Principal),
    'properties' : IDL.Vec(IDL.Tuple(IDL.Text, GenericValue)),
    'token_identifier' : IDL.Nat,
    'minted_at' : IDL.Nat64,
    'minted_by' : IDL.Principal,
  });
  const NftError = IDL.Variant({
    'SelfTransfer' : IDL.Null,
    'TokenNotFound' : IDL.Null,
    'TxNotFound' : IDL.Null,
    'SelfApprove' : IDL.Null,
    'OperatorNotFound' : IDL.Null,
    'Unauthorized' : IDL.Null,
    'ExistedNFT' : IDL.Null,
    'OwnerNotFound' : IDL.Null,
    'Other' : IDL.Text,
  });
  const Result_2 = IDL.Variant({
    'ok' : IDL.Vec(TokenMetadata),
    'err' : NftError,
  });
  const Result_3 = IDL.Variant({
    'ok' : IDL.Opt(IDL.Principal),
    'err' : NftError,
  });
  const Result_1 = IDL.Variant({ 'ok' : TokenMetadata, 'err' : NftError });
  const Result = IDL.Variant({ 'ok' : IDL.Nat, 'err' : NftError });
  return IDL.Service({
    'allTokenMetadata' : IDL.Func([], [Result_2], ['query']),
    'balanceOf' : IDL.Func([IDL.Principal], [IDL.Nat], ['query']),
    'callerTokenMetadata' : IDL.Func([], [Result_2], ['query']),
    'doIOwn' : IDL.Func([IDL.Nat], [IDL.Bool], ['query']),
    'greet' : IDL.Func([IDL.Text], [IDL.Text], []),
    'logo' : IDL.Func([], [IDL.Opt(IDL.Text)], ['query']),
    'mint' : IDL.Func([], [IDL.Nat], []),
    'name' : IDL.Func([], [IDL.Text], ['query']),
    'ownerOf' : IDL.Func([IDL.Nat], [Result_3], ['query']),
    'ownerTokenMetadata' : IDL.Func([IDL.Principal], [Result_2], ['query']),
    'symbol' : IDL.Func([], [IDL.Text], ['query']),
    'tokenMetadata' : IDL.Func([IDL.Nat], [Result_1], ['query']),
    'totalSupply' : IDL.Func([], [IDL.Nat], ['query']),
    'transferFrom' : IDL.Func(
        [IDL.Principal, IDL.Principal, IDL.Nat],
        [Result],
        [],
      ),
  });
};
export const init = ({ IDL }) => { return []; };
