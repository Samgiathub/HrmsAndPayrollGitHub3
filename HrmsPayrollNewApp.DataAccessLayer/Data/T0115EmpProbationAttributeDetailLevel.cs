using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0115EmpProbationAttributeDetailLevel
{
    public decimal RowId { get; set; }

    public decimal TranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal AttributeId { get; set; }

    public decimal AttrRating { get; set; }

    public decimal? FinalReview { get; set; }

    public string? ReviewType { get; set; }

    public virtual T0115EmpProbationMasterLevel Tran { get; set; } = null!;
}
