using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0500EssSkillCertificateDetail
{
    public decimal CertiDetailsId { get; set; }

    public decimal? CertiId { get; set; }

    public string? CertificateName { get; set; }

    public decimal? ExpYears { get; set; }

    public decimal? IsTrainingAttended { get; set; }

    public string IsTrainAttend { get; set; } = null!;

    public string? TrainingCertiAttachment { get; set; }

    public string TrainCertiattach { get; set; } = null!;

    public decimal? IsExamAttended { get; set; }

    public string IsExamAttend { get; set; } = null!;

    public string? ExamCertiAttachment { get; set; }

    public string ExamCertiattach { get; set; } = null!;

    public string? Descriptions { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }
}
