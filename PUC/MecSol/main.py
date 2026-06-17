from flask import Flask, request, jsonify
from flask_cors import CORS
from flask import render_template
from Back import solve

app = Flask(__name__)
CORS(app)


@app.route("/")
def homepage():
    return render_template("index.html")

@app.route("/Back", methods=["POST"])
def calcular():
    info = request.get_json()

    resultado = solve(info)

    return jsonify(resultado) 


if __name__ == "__main__":
    app.run(debug=True)