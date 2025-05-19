FROM n8nio/n8n:latest

# Робоча директорія
WORKDIR /home/node

# Перемістити локальні конфіги при потребі
# COPY ./n8n_data /home/node/.n8n

EXPOSE 5679

# Запуск n8n
CMD ["n8n"]