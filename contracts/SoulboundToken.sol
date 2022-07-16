//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import 'hardhat/console.sol';
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

import './lib/GatewayManager.sol';


contract SoulboundToken is Ownable, GatewayManager {
    using Address for address;

    // TODO: Mintable
    // TODO: Nontransferrable
    // TODO: Revokeable by issuer
    // TODO: Publicly visible

    mapping(uint256 => mapping(address => uint256)) private _balances;

    event TransferSingle(address indexed operator, address indexed to, uint256 id, uint256 value);
    event TransferBatch(address indexed operator, address indexed to, uint256[] ids, uint256[] values);

    error ZeroAddressError();
    error ArrayLengthMismatchError();

    /**
     * @dev See {GatewayManager-_addGateway}.
     */
    function addGateway(string memory _uri) public virtual onlyOwner {
        _addGateway(_uri);
    }

    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        if(account == address(0)) revert ZeroAddressError();
        return _balances[id][account];
    }

    function _mint(address to, uint256 id, uint256 amount, bytes memory data) internal virtual {
        if(to == address(0)) revert ZeroAddressError();

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, to, ids, amounts, data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, to, id, amount);

         _doSafeTransferAcceptanceCheck(operator, to, id, amount, data);
    }

    function _mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal virtual
    {
        if(to == address(0)) revert ZeroAddressError();
        if(ids.length != amounts.length) revert ArrayLengthMismatchError();

        address operator = _msgSender();

        _beforeTokenTransfer(operator, to, ids, amounts, data);

        uint len = ids.length;
        for (uint i; i < len; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, to, ids, amounts, data);
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }

    /**
     * @dev See {ERC1155-_beforeTokenTransfer}
     */
    function _beforeTokenTransfer(address operator, address to, uint256[] memory ids,
        uint256[] memory amounts, bytes memory data) internal virtual {}


    function _doSafeTransferAcceptanceCheck(address operator, address to, uint256 id,
        uint256 amount, bytes memory data) private
    {
        // TODO: Simplify this method for SoulBound
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, address(0), id, amount, data)
                returns (bytes4 response)
            {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(address operator, address to, uint256[] memory ids,
        uint256[] memory amounts, bytes memory data) private
    {
        // TODO: Simplify this method for SoulBound
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, address(0), ids, amounts, data)
                returns (bytes4 response)
            {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }



    /**
     * Deleted:
     * safeTransferFrom, safeBatchTransferFrom, _safeTransferFrom, _safeBatchTransferFrom, _setURI,
     * setApprovalForAll, _setApprovalForAll, _afterTokenTransfer
     */




    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;


//    /**
//     * @dev See {IERC165-supportsInterface}.
//     */
//    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
//        return
//        interfaceId == type(IERC1155).interfaceId ||
//        interfaceId == type(IERC1155MetadataURI).interfaceId ||
//        super.supportsInterface(interfaceId);
//    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }


    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
    public
    view
    virtual
    override
    returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }



    /**
     * @dev Destroys `amount` tokens of token type `id` from `from`
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens of token type `id`.
     */
    function _burn(address from, uint256 id, uint256 amount) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }








}