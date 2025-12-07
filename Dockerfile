# use AWS Lambda python runtime
FROM public.ecr.aws/lambda/python:3.12

# copy requirements and install
COPY requirements.txt ${LAMBDA_TASK_ROOT}
RUN pip install -r requirements.txt

# copy application code
COPY exif-cleaner.py ${LAMBDA_TASK_ROOT}

# set command to the handler function
CMD [ "exif-cleaner.handler" ]
