from flask import Flask, render_template, request, redirect, url_for

app = Flask(__name__)

# In-memory storage for tasks
tasks = []

@app.route('/', methods=['GET', 'POST'])
def home():
    if request.method == 'POST':
        task = request.form.get('task')
        if task:
            tasks.append(task)
        return redirect(url_for('home'))
    return render_template('index.html', tasks=tasks)

if __name__ == '__main__':
    app.run(debug=True)

app = Flask(__name__)

@app.route('/')
def home():
    return render_template('index.html')

if __name__ == '__main__':
    app.run(debug=True)
