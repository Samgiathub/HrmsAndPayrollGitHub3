using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0130TrainingFeedbackSuperDetail
{
    public decimal TrainingAppId { get; set; }

    public string TrainingTitle { get; set; } = null!;

    public string? TrainingDesc { get; set; }

    public DateTime ForDate { get; set; }

    public decimal? PostedEmpId { get; set; }

    public decimal SkillId { get; set; }

    public string AppStatus { get; set; } = null!;

    public decimal CmpId { get; set; }

    public decimal LoginId { get; set; }

    public DateTime SystemDate { get; set; }

    public decimal TrainingAprId { get; set; }

    public DateTime TrainingDate { get; set; }

    public string Place { get; set; } = null!;

    public string Faculty { get; set; } = null!;

    public string CompanyName { get; set; } = null!;

    public string? Description { get; set; }

    public decimal? TrainingCost { get; set; }

    public string AprStatus { get; set; } = null!;

    public decimal EmpId { get; set; }

    public string? SkillName { get; set; }

    public decimal? TrainingAprDetailId { get; set; }

    public decimal? EmpSId { get; set; }

    public string? EmpFeedback { get; set; }

    public string? SuperiorFeedback { get; set; }

    public DateTime? EmpFeedbackDate { get; set; }

    public DateTime? SupFeedbackDate { get; set; }

    public decimal? EmpEvalRate { get; set; }

    public decimal? SupEvalRate { get; set; }

    public string? IsAttend { get; set; }
}
