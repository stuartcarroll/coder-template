#===============================================================================
# Minimal Claude Code Development Container
# Fast-building with essentials + GitHub CLI
#===============================================================================

FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install essential packages + Python for SuperClaude
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    sudo \
    ca-certificates \
    gnupg \
    openssh-client \
    build-essential \
    locales \
    python3 \
    python3-pip \
    python3-venv \
    jq \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# Set locale
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

#===============================================================================
# Install GitHub CLI
#===============================================================================
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

#===============================================================================
# Install Node.js 22 LTS (required for Claude Code)
#===============================================================================
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

#===============================================================================
# Install Claude Code CLI only
#===============================================================================
RUN npm install -g @anthropic-ai/claude-code

#===============================================================================
# Create coder user
#===============================================================================
RUN useradd --create-home --shell /bin/bash coder \
    && mkdir -p /etc/sudoers.d \
    && echo "coder ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/coder \
    && chmod 440 /etc/sudoers.d/coder

#===============================================================================
# Switch to coder user
#===============================================================================
USER coder
WORKDIR /home/coder

# SuperClaude will be installed at runtime to avoid build complexity

#===============================================================================
# Create project directory
#===============================================================================
RUN mkdir -p /home/coder/projects

#===============================================================================
# Configure git
#===============================================================================
RUN git config --global init.defaultBranch main \
    && git config --global pull.rebase false


#===============================================================================
# Helper scripts and Claude configuration
#===============================================================================
RUN mkdir -p /home/coder/bin /home/coder/.claude
COPY --chown=coder:coder get-secret.sh /home/coder/bin/get-secret
COPY --chown=coder:coder init-claude-context.sh /home/coder/bin/init-claude-context
COPY --chown=coder:coder CLAUDE.md /home/coder/.claude/WORKSPACE_CONTEXT.md
COPY --chown=coder:coder claude-startup-prompt.md /home/coder/.claude/STARTUP_PROMPT.md
RUN chmod +x /home/coder/bin/get-secret /home/coder/bin/init-claude-context
ENV PATH="/home/coder/bin:$PATH"

#===============================================================================
# Expose ports
#===============================================================================
EXPOSE 8080

#===============================================================================
# Default command (Coder will override this)
#===============================================================================
CMD ["sleep", "infinity"]
