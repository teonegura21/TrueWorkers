class Contract {
  final String id;
  final String jobId;
  final String pdfUrl;
  final String hash;
  final ContractStatus status;

  const Contract({
    required this.id,
    required this.jobId,
    required this.pdfUrl,
    required this.hash,
    required this.status,
  });

  Contract copyWith({ContractStatus? status, String? pdfUrl}) => Contract(
        id: id,
        jobId: jobId,
        pdfUrl: pdfUrl ?? this.pdfUrl,
        hash: hash,
        status: status ?? this.status,
      );
}

enum ContractStatus { pendingSignatures, signed }

