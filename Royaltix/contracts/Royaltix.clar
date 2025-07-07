;; Royaltix NFT Marketplace Smart Contract

;; Define constants
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-listing-not-found (err u102))
(define-constant err-invalid-price (err u103))
(define-constant err-invalid-token-id (err u104))
(define-constant err-invalid-uri (err u105))
(define-constant err-invalid-royalty (err u106))
(define-constant err-invalid-new-owner (err u107))

;; Define NFT asset
(define-non-fungible-token royaltix-nft uint)

;; Define data variables
(define-data-var royaltix-owner principal tx-sender)
(define-data-var royaltix-next-id uint u1)

;; Define data maps
(define-map royaltix-tokens
  { token-id: uint }
  { owner: principal, creator: principal, uri: (string-ascii 256), royalty: uint }
)

(define-map royaltix-listings
  { token-id: uint }
  { price: uint, seller: principal }
)

;; Private function to check contract ownership
(define-private (is-royaltix-owner)
  (is-eq tx-sender (var-get royaltix-owner))
)

;; Transfer contract ownership (warning-safe)
(define-public (transfer-royaltix-ownership (new-owner principal))
  (begin
    (asserts! (is-royaltix-owner) err-owner-only)
    (asserts! (not (is-eq new-owner (var-get royaltix-owner))) err-invalid-new-owner)
    (ok (var-set royaltix-owner new-owner))
  )
)

;; Get current contract owner
(define-read-only (get-royaltix-owner)
  (ok (var-get royaltix-owner))
)

;; Mint new NFT
(define-public (royaltix-mint (uri (string-ascii 256)) (royalty uint))
  (let
    (
      (token-id (var-get royaltix-next-id))
    )
    (asserts! (> (len uri) u0) err-invalid-uri)
    (asserts! (<= royalty u1000) err-invalid-royalty)
    (try! (nft-mint? royaltix-nft token-id tx-sender))
    (map-set royaltix-tokens
      { token-id: token-id }
      { owner: tx-sender, creator: tx-sender, uri: uri, royalty: royalty }
    )
    (var-set royaltix-next-id (+ token-id u1))
    (ok token-id)
  )
)

;; List NFT for sale
(define-public (royaltix-list (token-id uint) (price uint))
  (let
    (
      (token-owner (unwrap! (nft-get-owner? royaltix-nft token-id) err-invalid-token-id))
    )
    (asserts! (> price u0) err-invalid-price)
    (asserts! (is-eq tx-sender token-owner) err-not-token-owner)
    (map-set royaltix-listings
      { token-id: token-id }
      { price: price, seller: tx-sender }
    )
    (ok true)
  )
)

;; Cancel NFT listing
(define-public (royaltix-cancel-listing (token-id uint))
  (let
    (
      (listing (unwrap! (map-get? royaltix-listings { token-id: token-id }) err-listing-not-found))
    )
    (asserts! (< token-id (var-get royaltix-next-id)) err-invalid-token-id)
    (asserts! (is-eq tx-sender (get seller listing)) err-not-token-owner)
    (map-delete royaltix-listings { token-id: token-id })
    (ok true)
  )
)

;; Buy NFT
(define-public (royaltix-buy (token-id uint))
  (let
    (
      (listing (unwrap! (map-get? royaltix-listings { token-id: token-id }) err-listing-not-found))
      (price (get price listing))
      (seller (get seller listing))
      (token (unwrap! (map-get? royaltix-tokens { token-id: token-id }) err-invalid-token-id))
      (creator (get creator token))
      (royalty (get royalty token))
      (royalty-amount (/ (* price royalty) u10000))
      (seller-amount (- price royalty-amount))
    )
    (asserts! (< token-id (var-get royaltix-next-id)) err-invalid-token-id)
    (try! (stx-transfer? royalty-amount tx-sender creator))
    (try! (stx-transfer? seller-amount tx-sender seller))
    (try! (nft-transfer? royaltix-nft token-id seller tx-sender))
    (map-set royaltix-tokens
      { token-id: token-id }
      (merge token { owner: tx-sender })
    )
    (map-delete royaltix-listings { token-id: token-id })
    (ok true)
  )
)

;; Get token details
(define-read-only (royaltix-get-token (token-id uint))
  (ok (unwrap! (map-get? royaltix-tokens { token-id: token-id }) err-invalid-token-id))
)

;; Get listing details
(define-read-only (royaltix-get-listing (token-id uint))
  (ok (unwrap! (map-get? royaltix-listings { token-id: token-id }) err-listing-not-found))
)