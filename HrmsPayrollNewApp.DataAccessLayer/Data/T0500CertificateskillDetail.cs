using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0500CertificateskillDetail
{
    public decimal CertiDetailId { get; set; }

    public decimal? CertiId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public string? SkillLevel { get; set; }

    public decimal? ExpYears { get; set; }

    public decimal? IsTrainingAttended { get; set; }

    public string? TrainingCertiAttachment { get; set; }

    public decimal? IsExamAttended { get; set; }

    public string? ExamCertiAttachment { get; set; }

    public string? Descriptions { get; set; }

    public decimal? CreatedBy { get; set; }

    public DateTime? CreatedDate { get; set; }

    public DateTime? CertExpDate { get; set; }
}
