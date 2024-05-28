import processing.net.*; //<>// //<>//
import java.io.*;

import java.nio.charset.StandardCharsets;
import java.net.Socket;

Socket socket;
BufferedReader reader;
String serverIP = "localhost";
int serverPort = 12345;

String username = "";
String password = "";
boolean loggedIn = false;
boolean inMatch = false;

int inputFieldHeight = 30;
int inputFieldWidth = 150;
int buttonHeight = 30;
int buttonWidth = 140;

HashMap<Integer, float[]> players = new HashMap<>();
int numStars = 100; // Number of stars
float[] starX = new float[numStars];
float[] starY = new float[numStars];


void setup() {
  fullScreen();
  textAlign(CENTER, CENTER);
  generateStars();

  try {
    socket = new Socket(serverIP, serverPort);
    reader = new BufferedReader(new InputStreamReader(socket.getInputStream()));
    socket.setSoTimeout(17);
    println("Connected to server");
  } catch (Exception e) {
      println("Connection failed");
      e.printStackTrace();
  }
}

void sendCommand(String command) {
    try {
        BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(socket.getOutputStream(), StandardCharsets.UTF_8));
        writer.write(command);
        writer.flush();
    } catch (IOException e) {
        e.printStackTrace();
    }
}

void readNetworkData() throws Exception {
  String data = "";
  try {
    if (reader.ready()) {
        data = reader.readLine();
        System.out.println(data);
    }
  } catch (Exception e) {
      System.out.println("Error reading input line: " + e.getMessage());
      e.printStackTrace();
      throw e;
  }

  String[] tokens = data.split(" ");
  if (tokens[0].equals("login_success")) {
    println("Logged in succesfully!");
    loggedIn = true;
  } else if (tokens[0].equals("Game_started") && loggedIn == true) {
    println("Game started!" + tokens[1]);
    sendCommand("gamePid " + tokens[1]);
    inMatch = true;
  } else if (tokens[0].equals("login_failed")) {
    println("Invalid username or password");
  } else if (tokens[0].equals("player_pos")) {
    int id = Integer.parseInt(tokens[1]);
    float x = Float.parseFloat(tokens[2]);
    float y = Float.parseFloat(tokens[3]);
    if (players.get(id) == null) {
      players.put(id, new float[] {x, y});
    } else {
      players.get(id)[0] = x;
      players.get(id)[1] = y;
    }
  }

}

void drawPlayer(int id) {
  if (players.get(id) == null) {
    return;
  }
  
  float[] coords = players.get(id);
  float x = coords[0];
  float y = coords[1];
  
  // Assign color based on ID
  color playerColor = getColorForPlayerID(id);
  fill(playerColor);
  
  ellipse(x, y, 20, 20);
}

color getColorForPlayerID(int id) {
  id = abs(id);
  if (id % 3 == 0) {
    return color(255, 0, 0); // Red
  } else if (id % 3 == 1) {
    return color(0, 255, 0); // Green
  } else {
    return color(0, 0, 255); // Blue
  }
}

void drawGame() {
  background(25, 25, 112);
  drawSun(width/2,height/2, 50);
  drawStars();
  for (Integer playerId : players.keySet()) {
    drawPlayer(playerId);
  }
}

void draw() {

  try {
    readNetworkData();
  } catch(Exception e) {
    e.printStackTrace();
  }

  if (!loggedIn) {
    background(25, 25, 112);
    drawStars();
    drawSun(4*width/5, height/5, 50);

    textSize(20);
    fill(128, 128, 128);
    rect(width/3 + 5, 3 * height/12 + 5, width/3, 4 * height/12);
    fill(192, 192, 192);
    rect(width/3, 3 * height/12, width/3, 4 * height/12);

    // Username input
    fill(0);
    text("Username:", width/2, height/3 - 20);
    fill(128, 128, 128);
    rect(width/2 - inputFieldWidth/2, height/3, inputFieldWidth, inputFieldHeight);
    fill(255);
    text(username, width/2, height/3 + inputFieldHeight/2);

    // Password input
    fill(0);
    text("Password:", width/2, height/3 + 50);
    fill(128, 128, 128);
    rect(width/2 - inputFieldWidth/2, height/3 + 70, inputFieldWidth, inputFieldHeight);
    fill(255);
    text(password.replaceAll(".", "*"), width/2, height/3 + 72 + inputFieldHeight/2);

    // Login button
    fill(128, 128, 128);
    rect(width/2 - buttonWidth - 10, height/3 + 130, buttonWidth, buttonHeight);
    fill(255);
    text("Login", width/2 - buttonWidth/2 - 10, height/3 + buttonHeight/2 + 130);

    // Create account button
    fill(128, 128, 128);
    rect(width/2 + 10, height/3 + 130, buttonWidth, buttonHeight);
    fill(255);
    text("Create Account", width/2 + buttonWidth/2 + 10, height/3 + buttonHeight/2 + 130);
  } else if (!inMatch && loggedIn) {
    background(25, 25, 112);
    alert("Logged in as " +  username + ". Waiting for players to join."); 
  } else {
    drawGame();
  }
  checkConnectionStatus(); // It just tells you the connection was active at some point
}

void mousePressed() {
  if (!loggedIn) {
    if (mouseX > width/2 - buttonWidth - 10 && mouseX < width/2 - 10 && mouseY > height/3 + 130 && mouseY < height/3 + 130 + buttonHeight) {
      // Perform login action
      checkCredentials(username, password);
    }

    // Check if the mouse is inside the create account button
    if (mouseX > width/2 + 10 && mouseX < width/2 + 10 + buttonWidth && mouseY > height/3 + 130 && mouseY < height/3 + 130 + buttonHeight) {
      // Perform create account action
      createAccount(username, password);
    }
  }
}

void keyPressed() {
  if (!loggedIn) {

    if (key != BACKSPACE && key != ENTER) {
      if (mouseX > width/2 - inputFieldWidth/2 && mouseX < width/2 + inputFieldWidth/2 && mouseY > height/3 && mouseY < height/3 + inputFieldHeight) {
        username += key;
      }
      if (mouseX > width/2 - inputFieldWidth/2 && mouseX < width/2 + inputFieldWidth/2 && mouseY > height/3 + 70 && mouseY < height/3 + 70 + inputFieldHeight) {
        password += key;
      }
    }

    if (key == BACKSPACE) {
      if (mouseX > width/2 - 50 && mouseX < width/2 + 150 && mouseY > height/2 - 20 && mouseY < height/2 + 10) {
        if (username.length() > 0) {
          username = username.substring(0, username.length() - 1);
        }
      }
      if (mouseX > width/2 - 50 && mouseX < width/2 + 150 && mouseY > height/2 + 40 && mouseY < height/2 + 70) {
        if (password.length() > 0) {
          password = password.substring(0, password.length() - 1);
        }
      }
    }

    if (key == ENTER) {
      checkCredentials(username, password);
    }
  }
  if (loggedIn && inMatch) {
    if (key == 'a' || key == 'A') {
        sendCommand("a");
    } else if (key == 'd' || key == 'D') {
        sendCommand("d");
    } else if (key == 'w' || key == 'W') {
        sendCommand("w");
    } else if (key == 'q' || key == 'Q') {
        sendCommand("q");
    }
  }
}

void clientEvent(Client c) {
    String serverResponse = c.readString();
    if (serverResponse != null) {
        println("Server response: " + serverResponse);
    }
}

void checkCredentials(String username, String password) {
  sendCommand("login " + username + " " + password);
}


void createAccount(String username, String password) {
  sendCommand("new_account " + username + " " + password);
}

void drawSun(int centerX, int centerY, int radius) {

  fill(255, 255, 0);
  ellipse(centerX, centerY, radius * 2, radius * 2);

  for (int i = 0; i < 3; i++) {
    int alpha = 150 - i * 50;
    fill(255, 255, 0, alpha);
    ellipse(centerX, centerY, (radius + 8 * (i + 1)) * 2, (radius + 8 * (i + 1)) * 2);
  }
}

void generateStars() {
  for (int i = 0; i < numStars; i++) {
    starX[i] = random(width);
    starY[i] = random(height);
  }
}

void drawStars() {
  fill(255);
  noStroke();
  for (int i = 0; i < numStars; i++) {
    ellipse(starX[i], starY[i], 2, 2);
  }
}

void alert(String message) {
    fill(128, 128, 128);
    rect(width/3 + 5, 1 * height/12 + 5, width/3, 1 * height/12);
    fill(192, 192, 192);
    rect(width/3, 1 * height/12, width/3, 1 * height/12);
    fill(0);
    textSize(20);
    text(message, width/2, height/8);
}

void checkConnectionStatus() {
  if (socket != null && socket.isBound() == true) {
    fill(0, 255, 0);
  } else {
    fill(255, 0, 0);
  }
  ellipse(15, height - 15, 20, 20);
}
