#! /usr/bin/env python

from dotenv import load_dotenv
load_dotenv()

import os
from torch import cuda

from transformers import pipeline, set_seed # type: ignore
from transformers.utils.logging import set_verbosity_error

from aiohttp import web

def ensure_cache_exists(cache_path):
    if not os.path.exists(cache_path):
        os.makedirs(cache_path)


def make_pipeline(model):

    # determine the pipeline device (-1 => CPU)
    device = -1
    if cuda.is_available():
        # if we have gpus, run on the zeroth one
        device = 0

    
    pipe = pipeline(
        task='text-generation',
        model=model,
        device=device
    )


    return pipe



def create_generation_route(model):
    pipe = make_pipeline(model)

    async def handler(request):
        body = await request.json()

        max_length = 256
        if 'max_length' in body and body['max_length'] is not None:
            max_length = body['max_length']

        prompt = body['prompt']

        results = pipe(
            prompt,
            max_length=max_length,
            num_return_sequences=1
        )

        result = results[0]['generated_text'].strip()

        # result = result[len(prompt):]

        print(f'{body["prompt"]} => {result}')

        return web.json_response({
            'result': result,
            'ok': True
        })

    return handler


async def alive_handler(request):
    print('alive!')
    return web.json_response({
        'ok': True
    })


if __name__ == '__main__':
    set_verbosity_error()

    CACHE_PATH = os.environ['TRANSFORMERS_CACHE']
    LANGUAGE_MODEL = os.environ['LANGUAGE_MODEL']
    APP_PORT = int(os.environ['APP_PORT'])

    print(f'loading language model {LANGUAGE_MODEL}')

    # initial setup
    ensure_cache_exists(CACHE_PATH)

    # load in the pipeline
    generation_handler = create_generation_route(LANGUAGE_MODEL)

    # install the routes
    app = web.Application()
    app.add_routes([
        web.post('/api/v0/generate', generation_handler),
        web.get('/api/v0/alive', alive_handler)
    ])

    # run!
    web.run_app(app, host='0.0.0.0', port=APP_PORT)

