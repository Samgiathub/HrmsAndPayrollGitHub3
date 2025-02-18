using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0130ReportTraining
{
    public decimal EmpId { get; set; }

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

    public string Attend { get; set; } = null!;

    public decimal EmpRate { get; set; }

    public decimal SupRate { get; set; }

    public DateTime TrainingDate { get; set; }

    public decimal? TrainingCost { get; set; }

    public string AprStatus { get; set; } = null!;

    public string Faculty { get; set; } = null!;

    public string Place { get; set; } = null!;

    public string CompanyName { get; set; } = null!;

    public string? Description { get; set; }

    public DateTime? SupFeedbackDate { get; set; }

    public DateTime? EmpFeedbackDate { get; set; }

    public string? SuperiorFeedback { get; set; }

    public string? EmpFeedback { get; set; }

    public decimal? EmpSId { get; set; }

    public decimal? TrainingAprDetailId { get; set; }
}
