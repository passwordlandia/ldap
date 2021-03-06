# the upstream component NGINX needs to connect to
upstream django {
	server unix:/run/uwsgi/apivndeveloper.sock;
}

# configuration of the server
server {
	listen		80;
	server_name 	api.vndeveloper.com;
	charset		utf-8;
	# max upload size
	client_max_body_size 75M;
	# Django media & static
	location /media  {
		alias /var/www/apivndeveloper/media;
	}
	location /static {
		alias /var/www/apivndeveloper/static;
	}
	# Finally, send all non-media requests to the Django server.
	location / {
		uwsgi_pass  django;
		include uwsgi_params;
		
		uwsgi_param Host $host;
		uwsgi_param X-Real-IP $remote_addr;
		uwsgi_param X-Forwarded-For $proxy_add_x_forwarded_for;
		uwsgi_param X-Forwarded-Proto $http_x_forwarded_proto;
	}
}
