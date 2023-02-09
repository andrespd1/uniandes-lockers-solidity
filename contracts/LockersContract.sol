// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

contract Lockers{
    address payable uniandes;
    address payable estudiante;
    uint public num_lockers;
    uint public num_contratos;

    struct Locker{
        uint lockerId;
        uint numContrato;
        string edificio;
        string tamano;
        uint precio_dia;
        uint timestamp;
        bool libre;
        address payable uniandes;
        address payable estudianteActual;
    } 
    mapping(uint => Locker) public Locker_por_Num;

    struct ContratoLocker{
        uint lockerId;
        uint numContrato;
        string edificio;
        string tamano;
        uint precio_dia_dia;
        uint duracionContrato;
        uint timestamp;
        address payable uniandes;
        address payable estudiante;
    } 
    mapping(uint => ContratoLocker) public Contrato_por_Num;

    modifier soloUniandes(uint _index) {
        require(payable(msg.sender) == Locker_por_Num[_index].uniandes, "Solo la Universidad de los Andes tiene acceso a esta funcion");
        _;
    }

    modifier noUniandes(uint _index) {
        require(payable(msg.sender) != Locker_por_Num[_index].uniandes, "Solo los estudiantes tienen acceso a esta funcion");
        _;
    }

    modifier duenoLocker(uint _index) {
        require(payable(msg.sender) == Locker_por_Num[_index].estudianteActual, "Solo el dueno puede liberar el locker");
        _;
    }

    modifier soloLibre(uint _index){
        
        require(Locker_por_Num[_index].libre == true, "Este locker esta actualmente ocupado.");
        _;
    }

    modifier fondosSuficientes(uint _index, uint _duracion_contrato) {
        require(msg.value >= (uint(Locker_por_Num[_index].precio_dia) * _duracion_contrato), "Fondos insuficientes");
        _;
    }

    modifier ExpiraContrato(uint _index) {
        uint _numContrato = Locker_por_Num[_index].numContrato;
        uint tiempo = Contrato_por_Num[_numContrato].timestamp + Contrato_por_Num[_numContrato].duracionContrato;
        require(block.timestamp > tiempo, "El contrato no ha expirado");
        _;
    }

    function anadirLocker(string memory _edificio, string memory _tamano, uint _precio_dia) public {
        require(payable(msg.sender) != address(0));
        num_lockers ++;
        bool _libre = true;
        Locker_por_Num[num_lockers] = Locker(num_lockers,0,_edificio,_tamano,_precio_dia,0,_libre, payable(msg.sender) , payable(address(0))); 
        
    }

    function firmarContrato(uint _index, uint _duracion_contrato) public payable noUniandes(_index) fondosSuficientes(_index, _duracion_contrato) soloLibre(_index) {
        require(payable(msg.sender) != address(0));
        address payable _uniandes = Locker_por_Num[_index].uniandes;
        uint precio_total = Locker_por_Num[_index].precio_dia * _duracion_contrato;
        _uniandes.transfer(precio_total);
        num_contratos++;
        Locker_por_Num[_index].estudianteActual = payable(msg.sender);
        Locker_por_Num[_index].libre = false;
        Locker_por_Num[_index].timestamp = block.timestamp;
        Locker_por_Num[_index].numContrato = num_contratos;
        Contrato_por_Num[num_contratos]=ContratoLocker(_index,num_contratos,Locker_por_Num[_index].edificio,Locker_por_Num[_index].tamano,Locker_por_Num[_index].precio_dia,_duracion_contrato,block.timestamp,_uniandes,payable(msg.sender));
       

    }
   
    function contratoTerminado(uint _index) public payable soloUniandes(_index) ExpiraContrato(_index){
    require(payable(msg.sender) != address(0));
    require(Locker_por_Num[_index].libre == false, "El locker sigue en uso.");
    Locker_por_Num[_index].libre = true;
    }

    function entregarLocker(uint _index) public noUniandes(_index) duenoLocker(_index){
        require(payable(msg.sender) != address(0));
        Locker_por_Num[_index].libre = true;
    }
}