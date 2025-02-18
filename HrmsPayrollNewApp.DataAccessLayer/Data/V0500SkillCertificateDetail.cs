using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0500SkillCertificateDetail
{
    public decimal CertiDetailsId { get; set; }

    public decimal? CertiId { get; set; }

    public string? CertificateName { get; set; }

    public decimal? ExpYears { get; set; }

    public decimal? IsTrainingAttended { get; set; }

    public string IsTrainAttend { get; set; } = null!;

    public string? TrainCertiattach { get; set; }

    public decimal? IsExamAttended { get; set; }

    public string IsExamAttend { get; set; } = null!;

    public string? ExamCertiattach { get; set; }

    public string? Descriptions { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public string CertExpDate { get; set; } = null!;
}
