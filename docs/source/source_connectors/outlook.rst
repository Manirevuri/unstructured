Outlook
==========
Connect Outlook to your preprocessing pipeline, and batch process all your documents using ``unstructured-ingest`` to store structured outputs locally on your filesystem.

First you'll need to install the Outlook dependencies as shown here.

.. code:: shell

  pip install "unstructured[outlook]"

Run Locally
-----------

.. tabs::

   .. tab:: Shell

      .. code:: shell

        unstructured-ingest \
            outlook \
            --client-id "$MS_CLIENT_ID" \
            --client-cred "$MS_CLIENT_CRED" \
            --tenant "$MS_TENANT_ID" \
            --user-email "$MS_USER_EMAIL" \
            --outlook-folders Inbox,"Sent Items" \
            --output-dir outlook-output \
            --num-processes 2 \
            --recursive \
            --verbose

   .. tab:: Python

      .. code:: python

        import os

        from unstructured.ingest.interfaces import PartitionConfig, ReadConfig
        from unstructured.ingest.runner.outlook import outlook

        if __name__ == "__main__":
            outlook(
                verbose=True,
                read_config=ReadConfig(),
                partition_config=PartitionConfig(
                    output_dir="outlook-output",
                    num_processes=2,
                ),
                client_id=os.getenv("MS_CLIENT_ID"),
                client_cred=os.getenv("MS_CLIENT_CRED"),
                tenant=os.getenv("MS_TENANT_ID"),
                user_email=os.getenv("MS_USER_EMAIL"),
                outlook_folders=["Inbox", "Sent Items"],
                recursive=True,
            )

Run via the API
---------------

You can also use upstream connectors with the ``unstructured`` API. For this you'll need to use the ``--partition-by-api`` flag and pass in your API key with ``--api-key``.

.. tabs::

   .. tab:: Shell

      .. code:: shell

        unstructured-ingest \
          airtable \
          --metadata-exclude filename,file_directory,metadata.data_source.date_processed \
          --personal-access-token "$AIRTABLE_PERSONAL_ACCESS_TOKEN" \
          --output-dir airtable-ingest-output \
          --num-processes 2 \
          --reprocess \
          --partition-by-api \
          --api-key "<UNSTRUCTURED-API-KEY>"

   .. tab:: Python

      .. code:: python

        import os

        from unstructured.ingest.interfaces import PartitionConfig, ReadConfig
        from unstructured.ingest.runner.outlook import outlook

        if __name__ == "__main__":
            outlook(
                verbose=True,
                read_config=ReadConfig(),
                partition_config=PartitionConfig(
                    output_dir="outlook-output",
                    num_processes=2,
                    partition_by_api=True,
                    api_key=os.getenv("UNSTRUCTURED_API_KEY"),
                ),
                client_id=os.getenv("MS_CLIENT_ID"),
                client_cred=os.getenv("MS_CLIENT_CRED"),
                tenant=os.getenv("MS_TENANT_ID"),
                user_email=os.getenv("MS_USER_EMAIL"),
                outlook_folders=["Inbox", "Sent Items"],
                recursive=True,
            )

Additionally, you will need to pass the ``--partition-endpoint`` if you're running the API locally. You can find more information about the ``unstructured`` API `here <https://github.com/Unstructured-IO/unstructured-api>`_.

For a full list of the options the CLI accepts check ``unstructured-ingest outlook --help``.

NOTE: Keep in mind that you will need to have all the appropriate extras and dependencies for the file types of the documents contained in your data storage platform if you're running this locally. You can find more information about this in the `installation guide <https://unstructured-io.github.io/unstructured/installing.html>`_.
