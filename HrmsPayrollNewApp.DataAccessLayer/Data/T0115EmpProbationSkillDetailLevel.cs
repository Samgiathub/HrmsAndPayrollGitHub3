using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0115EmpProbationSkillDetailLevel
{
    public decimal RowId { get; set; }

    public decimal TranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal SkillId { get; set; }

    public decimal SkillRating { get; set; }

    public decimal? FinalReview { get; set; }

    public string? ReviewType { get; set; }

    public string Strengths { get; set; } = null!;

    public string OtherFactors { get; set; } = null!;

    public string Remarks { get; set; } = null!;

    public virtual T0115EmpProbationMasterLevel Tran { get; set; } = null!;
}
