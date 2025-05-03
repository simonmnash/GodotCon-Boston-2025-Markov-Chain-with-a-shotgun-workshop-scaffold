# Markov Chain with a Shotgun - GodotCon Boston 2025
## GodotCon Boston 2025 Workshop Scaffolding

This repo contains some scaffolding for a GodotCon workshop on how to reliably use small and open language models as components in larger procedural generation pipelines and game systems.

## Setup
Running open-weight models locally can be tricky - so even though the workshop focuses on models that can be run on a normal gaming computer, there is some network scaffolding that wraps both Ollama (local) and OpenRouter (remote). Time permitting we can get into the gory details of these wrappers, but the focus of the workshop is going to be abstracted.
The `local` variable on `Globals.tscn` is a global variable used to determine whether requests are kept local or sent to OpenRouter.
  
## Local Models (Ollama)

If you'd like to run language models locally during the workshop - install Ollama (https://ollama.com/) and run `ollama run gemma3:1b` ahead of the workshop.
This should consume less than one GB of VRAM, but laptops without a dedicated graphics card are likely to struggle. Tested on Pop!_OS with a Nvidia 3060 and a laptop with a 2060.

## Remote Models (OpenRouter) API Key Setup

An OpenRouter API key will be provided during the workshop. You can also sign up for an account and access free tier models without entering any billing information.
1. Create a file named `api_key.txt` in the `utils/` directory
2. Paste your API key in this file without any additional text or whitespace
3. The file should look like this:
   ```
   your-api-key-here
   ```
