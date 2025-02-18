using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100EmpProbationAttributeDetail
{
    public decimal ProbAttrId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? AttrRating { get; set; }

    public decimal AttributeId { get; set; }

    public decimal EmpProbId { get; set; }

    public decimal? FinalReview { get; set; }

    public string? ReviewType { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0095EmpProbationMaster EmpProb { get; set; } = null!;
}
