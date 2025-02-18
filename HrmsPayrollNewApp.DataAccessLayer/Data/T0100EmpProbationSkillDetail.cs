using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100EmpProbationSkillDetail
{
    public decimal ProbSkillId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? SkillRating { get; set; }

    public decimal SkillId { get; set; }

    public decimal EmpProbId { get; set; }

    public decimal? FinalReview { get; set; }

    public string? ReviewType { get; set; }

    public string Strengths { get; set; } = null!;

    public string OtherFactors { get; set; } = null!;

    public string Remarks { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0095EmpProbationMaster EmpProb { get; set; } = null!;
}
