pragma solidity ^0.4.22;

// 一、商品訊息不易驗證，會導致商品資訊也不正確，若未及時發現，可能會造成多方面的消費糾紛；
// 二、B2C商品流程不同步（或同步需要大量成本）導致成本變高，不利於各方發展
contract transaction {
    address public chairperson;
    bytes public chairperson_name;
    
    //base information
    uint16 transaction_id;
    enum Transaction_type { B2B, B2C, C2C, C2B, CLOSE }

    struct Product{
        Transaction_type transaction_type;
        address seller;
        address buyer;
        //product information
        uint product_id;
        bytes product_name;
        bytes product_style;
        uint product_price;
        uint paied;
        bytes product_remarks;
        bool seller_verified;
        bool buyer_verified;
        uint order_time;
        uint completed_time;
    }
    struct Valuation{
        //transaction valuation
        uint buyer_logistics_valuation;
        uint buyer_Product_valuation;
        uint seller_logistics_valuation;
        uint sellerProduct_valuation;
        uint buyer_valution;
        uint seller_valution;
    }
    
    mapping(uint => Product ) products;
    mapping(uint => Valuation) valuations;
    constructor(bytes _chairperson) public {
        chairperson_name = _chairperson;
        chairperson = msg.sender;
        transaction_id = 0;
    }
    function createTransaction( address _seller, 
                                address _buyer, 
                                Transaction_type _transaction_type,
                                uint _product_id, 
                                bytes _product_name,
                                bytes _product_style, 
                                uint _product_price,
                                bytes _product_remarks,
                                uint _paied) public{
        require(
            msg.sender == chairperson,
            "Only chairperson can create transaction"
        );
        products[transaction_id] = Product({
                                            transaction_type:_transaction_type,
                                            seller: _seller,
                                            buyer : _buyer,
                                            product_id:_product_id,
                                            product_name:_product_name,
                                            product_style:_product_style,
                                            product_price:_product_price,
                                            product_remarks:_product_remarks,
                                            paied : _paied,
                                            seller_verified:false,
                                            buyer_verified:false,
                                            order_time : 0,
                                            completed_time : 0
        });
        valuations[transaction_id] =Valuation({
                                            buyer_logistics_valuation:0,
                                            buyer_Product_valuation:0,
                                            seller_logistics_valuation:0,
                                            sellerProduct_valuation:0,
                                            seller_valution:0,
                                            buyer_valution:0
        });
    }
    
    //買家下單，凍結金額
    function buyer_verify(uint _product_id, bool _verify)public payable{
        require(
            products[_product_id].transaction_type == Transaction_type.CLOSE,
            "The transaction has been close"
        );
        
        require(
            msg.sender == products[_product_id].buyer,
            "Only buyer can verify."
        );
        products[_product_id].buyer_verified = _verify;
        
        require(
            msg.value >= products[_product_id].product_price,
            "Didn't have enough money."
        );
        products[_product_id].paied = msg.value;
        products[_product_id].order_time = block.timestamp;
    }
    
    //賣家接單，合約成立
    function seller_verify(uint _product_id, bool _verify)public payable{
        require(
            msg.sender == products[_product_id].seller,
            "Only seller can verify."
        );
        if (_verify == false){
            products[_product_id].transaction_type = Transaction_type.CLOSE;
            revert();
        }
        products[_product_id].seller_verified = _verify;
        
        products[_product_id].completed_time = block.timestamp;
    }
    
    //買家收貨，金額轉帳，合約結束
    function buyer_receipt(uint _product_id)public payable{
        require(
            msg.sender == products[_product_id].buyer,
            "Only buyer can verify."
        );
        
        require(
            (products[_product_id].seller_verified == true) && (products[_product_id].buyer_verified == true),
            "The Transaction isn't verified"
        );
        
        products[_product_id].seller.transfer(products[_product_id].paied);
    }
    function seller_receipt(uint _product_id)public payable{
        require(
            msg.sender == products[_product_id].seller,
            "Only seller can verify."
        );
        
        require(
            (products[_product_id].seller_verified == true) && (products[_product_id].buyer_verified == true),
            "The Transaction isn't verified"
        );
        
         require(
            block.timestamp >= products[_product_id].completed_time + 14 days,
            "The Transaction dosen't expire."
        );
        
        products[_product_id].seller.transfer(products[_product_id].paied);
    }
    
    function cancel_transaction(uint _product_id)public payable{
        require(
            msg.sender == chairperson,
            "Only chairperson can cancel transaction"
        );
        
        products[_product_id].buyer.transfer(products[_product_id].paied);
        products[_product_id].seller_verified = false;
        products[_product_id].buyer_verified = false;
    }
    
    function buyer_logistics_valuation(uint _product_id, uint valution )public{
        valuations[_product_id].buyer_logistics_valuation = valution;
    }
    
    function buyer_Product_valuation(uint _product_id, uint valution )public{
        valuations[_product_id].buyer_Product_valuation = valution;
    }
    
    function seller_logistics_valuation(uint _product_id, uint valution )public{
        valuations[_product_id].seller_logistics_valuation = valution;
    }
    
    function sellerProduct_valuation(uint _product_id, uint valution )public{
        valuations[_product_id].sellerProduct_valuation = valution;
    }
    
    function buyer_valution(uint _product_id, uint valution )public{
        valuations[_product_id].buyer_valution = valution;
    }
    
    function seller_valution(uint _product_id, uint valution )public{
        valuations[_product_id].seller_valution = valution;
    }
}