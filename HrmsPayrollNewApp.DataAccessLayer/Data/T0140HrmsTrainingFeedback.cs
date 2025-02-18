using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0140HrmsTrainingFeedback
{
    public decimal TranFeedbackId { get; set; }

    public decimal TranEmpDetailId { get; set; }

    public decimal CmpId { get; set; }

    public int? IsAttend { get; set; }

    public string? Reason { get; set; }

    public decimal? EmpScore { get; set; }

    public string? EmpComments { get; set; }

    public string? EmpSuggestion { get; set; }

    public decimal? SupScore { get; set; }

    public string? SupComments { get; set; }

    public string? SupSuggestion { get; set; }

    public decimal? EmpSId { get; set; }

    public int? Status { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster? EmpS { get; set; }

    public virtual T0130HrmsTrainingEmployeeDetail TranEmpDetail { get; set; } = null!;
}
