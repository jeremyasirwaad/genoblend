// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// Bring in Phoenix channels client library:
import {Socket} from "phoenix"

// And connect to the path in "lib/genoblend_web/endpoint.ex". We pass the
// token for authentication. Read below how it should be used.
let socket = new Socket("/socket", {params: {token: window.userToken}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/genoblend_web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/genoblend_web/templates/layout/app.html.heex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/3" function
// in "lib/genoblend_web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket, _connect_info) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1_209_600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, connect to the socket:
socket.connect()

// Now that you are connected, you can join channels with a topic.
// Connect to the lobby channel to receive real-time gene updates:
let channel = socket.channel("room:lobby", {})
channel.join()
  .receive("ok", resp => { console.log("Joined lobby successfully", resp) })
  .receive("error", resp => { console.log("Unable to join lobby", resp) })

// Listen for genes_update events broadcasted by GenepoolBroadcaster
channel.on("genes_update", payload => {
  console.log("Received genes update:", payload)
  // payload contains:
  // {
  //   genes: [...], // Array of gene objects
  //   timestamp: "2025-01-08T12:00:00Z"
  // }
  
  // You can now update your UI with the gene data
  updateGenesUI(payload.genes)
})

// Example function to update UI with gene data
function updateGenesUI(genes) {
  // Implement your UI update logic here
  console.log(`Updating UI with ${genes.length} genes`)
  // Example: Update a genes list in the DOM
  // const genesList = document.getElementById('genes-list')
  // genesList.innerHTML = genes.map(gene => 
  //   `<div class="gene" style="background-color: ${gene.color}">
  //     <h3>${gene.name}</h3>
  //     <p>${gene.description}</p>
  //     <p>Position: (${gene.x_coordinate}, ${gene.y_coordinate})</p>
  //     <p>Traits: ${gene.traits.join(', ')}</p>
  //   </div>`
  // ).join('')
}

export default socket
