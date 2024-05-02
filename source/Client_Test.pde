import java.io.*;
import java.net.Socket;
import java.nio.charset.StandardCharsets;
import java.util.Scanner;

Socket socket;
BufferedReader reader;
float sunX, sunY;
float planetX, planetY;

void setup() {
    size(800, 600);
    // Connect to the server
    try {
        socket = new Socket("localhost", 12345); // Change localhost and port as needed
        reader = new BufferedReader(new InputStreamReader(socket.getInputStream()));
    } catch (IOException e) {
        e.printStackTrace();
    }
    sunX = width / 2;
    sunY = height / 2;
}

void draw() {
    background(255);
    drawSun();
    drawPlanet();
    readPlanetCoordinates();
}

void drawSun() {
    fill(255, 255, 0); // Yellow color for the sun
    ellipse(sunX, sunY, 50, 50); // Draw the sun at the center of the screen
}

void drawPlanet() {
    fill(0, 0, 255); // Blue color for the planet
    ellipse(planetX, planetY, 20, 20); // Draw the planet at the received coordinates
}

void readPlanetCoordinates() {
    try {
        if (reader.ready()) {
            String[] coordinates = reader.readLine().split(",");
            System.out.println(coordinates[0]);
            planetX = Float.parseFloat(coordinates[0]);
            planetY = Float.parseFloat(coordinates[1]);
        }
    } catch (IOException e) {
        System.out.println("Error reading input line: " + e.getMessage());
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

void keyPressed() {
    if (key == 'a' || key == 'A') {
        sendCommand("a"); //<>//
    } else if (key == 'd' || key == 'D') {
        sendCommand("d");
    } else if (key == 'w' || key == 'W') {
        sendCommand("w");
    } else if (key == 'q' || key == 'Q') {
        sendCommand("q"); //<>//
    }
}
