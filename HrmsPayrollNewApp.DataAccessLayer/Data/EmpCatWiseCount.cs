using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class EmpCatWiseCount
{
    public decimal CountId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? CatId { get; set; }

    public decimal? CatCount { get; set; }

    public string? Result { get; set; }
}
