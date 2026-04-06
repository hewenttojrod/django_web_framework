FROM node:18-bullseye

ENV PWDEBUG=0

WORKDIR /app

# Copy UI test sources and package manifest into the image
COPY ui-tests/ /app/ui-tests/

# Install project dependencies for UI tests and Playwright browsers
RUN if [ -f /app/ui-tests/package-lock.json ]; then \
			cd /app/ui-tests && npm ci --silent; \
		else \
			cd /app/ui-tests && npm install --silent; \
		fi && \
		cd /app/ui-tests && npx playwright install --with-deps

WORKDIR /app/ui-tests

# Keep container running; tests are baked into the image
CMD ["tail", "-f", "/dev/null"]
