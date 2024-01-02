from flask import Flask, render_template, request
import numpy as np
import pickle

app = Flask(__name__)
model = pickle.load(open('xgbm.pkl', 'rb'))

@app.route('/',methods=['GET'])
def Home():
    return render_template('index.html')


@app.route("/predict", methods=['POST'])
def predict():
    if request.method == 'POST':
        Year = float(request.form['Year'])

        Kilometers_Driven = float(request.form['Kilometers_Driven'])

        Engine = float(request.form['Engine'])

        Power = float(request.form['Power'])

        Seats = float(request.form['Seats'])

        Mileage = float(request.form['Mileage'])

        Location = int(request.form['Location'])
        
        Fuel_Type = int(request.form['Fuel_Type'])

        Transmission = int(request.form['Transmission'])

        Owner_Type = int(request.form['Owner_Type'])

        Brand = int(request.form['Brand'])
        

        value = np.array([[Location,Year,Kilometers_Driven,Engine,Fuel_Type,Transmission,Owner_Type,Mileage,Power,Seats,Brand]])
        pred = model.predict(value)
        pred = np.exp(pred[0])


        return render_template('result.html', prediction=np.round(pred,2))



if __name__ == "__main__":
    app.run(host='0.0.0.0',port=8080)
    # app.run(debug=True)



