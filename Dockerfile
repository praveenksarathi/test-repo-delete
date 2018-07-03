#The repository from which Flask is pulled in
FROM tiangolo/uwsgi-nginx-flask:flask

MAINTAINER praveenksarathi

#Moving the base application folder to Flask/app/ folder
COPY ./app /app

# tell the port number the container should expose
EXPOSE 5000

# Command to run the program
CMD ["python", "./app_delete.py","-p 5000"]
