    <html>
    <p id="pub"></p>
    <p id="bal"></p>
    <p id="bal"></p>
    <textarea id="msg" rows="6" cols="80"></textarea>
    <button type="button" id="send_button">Send Message</button>
    <ul id="messages" style="list-style: none; padding: 0; margin: 0;"></ul>
    <head>
    </head>
    <script>

function url(port) {
    return "http://localhost:".concat(port.toString().concat("/"));
}
PORT = 7669;
// my_port = 7668;
my_port = 7667;
function get(s) {
    s = JSON.stringify(s);
    u = url(my_port);
    u = u.concat(btoa(s));
    xmlhttp=new XMLHttpRequest();
    xmlhttp.open("GET",u,false);
    xmlhttp.send();
    out = xmlhttp.responseText;
    return out;
}
function local_get(s) {
    u = url(my_port + 1000);
    u = u.concat("priv/");
    s = JSON.stringify(s);
    u = u.concat(btoa(s));
    xmlhttp=new XMLHttpRequest();
    xmlhttp.open("GET",u,false);
    xmlhttp.send();
    out = xmlhttp.responseText;
    return out;
}
function add_message(message) {
    var ul = document.getElementById("messages");
    var li = document.createElement("li");
    li.innerHTML = '<font color="#000000">'.concat(message).concat('</font>');
    ul.appendChild(li);
}
function recieve_message(message) {
    var ul = document.getElementById("messages");
    var li = document.createElement("li");
    li.innerHTML = '<font color="#FF0000">____'.concat(message).concat('</font>');
    ul.appendChild(li);
}
function empty_messages() {
    var ul = document.getElementById("messages");
    ul.innerHTML = '';
}
function peers() { return JSON.parse(local_get("inbox_peers")); } 
function network_peers() { return JSON.parse(get("all_peers")); } 
function message(index, pub) {return JSON.parse(local_get("read_message&".concat(index).concat("&").concat(pub))); }
function refresh_messages() {
    empty_messages();
    pub = peers()[0];
    // console.log(pub.concat(" our peer"));
    size = local_get("inbox_size&".concat(pub));
    console.log("size ".concat(size));
    for (i = 0; i < size; i++) {
	msg = message(i, pub);
	if (msg.to == pub) {
	    add_message(msg.msg);
	} else {
	    recieve_message(msg.msg);
	}
    }
}
var send_button = document.getElementById("send_button");
send_button.onclick=function() {
    var msg = document.getElementById("msg").value;
    var peer = network_peers()[0];//this grabs the wrong peer sometimes
    // console.log("peer ".concat(peer));
    peer.ip = "localhost"; // this isn't supposed to be my port, it is the server's port.
    peer.port = PORT; // this isn't supposed to be my port, it is the server's port.
    // maybe use the hd of the list, but change the port to be correct?
    URL = "send_message&".concat(JSON.stringify(peer)).concat("&").concat(pub).concat("&").concat(JSON.stringify(msg));
    console.log("url ".concat(URL));
    // b = get("".concat(JSON.stringify(peer)).concat("&").concat(pub).concat("&").concat(JSON.stringify(msg)));
    b = local_get(URL);
    refresh();
    // console.log("message: ".concat(b.value));
};

function refresh_balance() {
    status = get("status");
    pub = JSON.parse(status).pubkey;
    document.getElementById("pub").innerHTML = "pubkey: ".concat(pub);
    acc = get("kv&".concat(pub));
    cpeers = JSON.parse(local_get("channel_peers"));
    console.log(cpeers[0]);
    
    bal2 = local_get("channel_balance&".concat(cpeers[0]));
    console.log("channel balance: ".concat(bal2));
    

    amount = JSON.parse(acc).amount;
    // document.getElementById("bal").innerHTML = "balance: ".concat(amount);
    document.getElementById("bal").innerHTML = "balance: ".concat(bal2);
}
function refresh() {
    refresh_balance();
    refresh_messages();
}

refresh();
</script>
    </html>