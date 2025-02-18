using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class CertiDetailId
{
    public decimal CertiDetailId1 { get; set; }

    public decimal? CertiId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public string? SkillLevel { get; set; }

    public decimal? ExpYears { get; set; }

    public int? IsTrainingAttended { get; set; }

    public string? TrainingCertiAttachment { get; set; }

    public int? IsExamAttended { get; set; }

    public string? ExamCertiAttachment { get; set; }

    public string? Descriptions { get; set; }

    public decimal? CreatedBy { get; set; }

    public DateTime? CreatedDate { get; set; }
}
