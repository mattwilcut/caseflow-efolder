require "vva"

# Thin interface to talk to Virtual VA
class ExternalApi::VVAService
  def self.fetch_documents_for(download)
    @vva_client ||= init_client
    documents ||= MetricsService.record("VVA: get document list for: #{download.file_number}",
                                        service: :vva,
                                        name: "document_list.get_by_claim_number") do
      @vva_client.document_list.get_by_claim_number(download.file_number)
    end
    Rails.logger.info("VVA Document list length: #{documents.length}")
    documents
  end

  def self.fetch_document_file(document)
    @vva_client ||= init_client
    result ||= MetricsService.record("VVA: fetch document content for: #{document.document_id}",
                                     service: :vva,
                                     name: "document_content.get_by_document_id") do
      @vva_client.document_content.get_by_document_id(
        document_id: document.document_id,
        source: document.source,
        format: document.preferred_extension,
        jro: document.jro,
        ssn: document.ssn
      )
    end
    result && result.content
  end

  def self.init_client
    VVA::Services.new(
      wsdl: Rails.application.config.vva_wsdl,
      username: ENV["VVA_USERNAME"],
      password: ENV["VVA_PASSWORD"],
      ssl_cert_key_file: ENV["VVA_KEY_LOCATION"],
      ssl_cert_file: ENV["VVA_CERT_LOCATION"],
      ssl_ca_cert: ENV["VVA_CA_CERT_LOCATION"]
    )
  end
end
