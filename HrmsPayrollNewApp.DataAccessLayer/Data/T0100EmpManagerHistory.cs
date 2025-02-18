using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100EmpManagerHistory
{
    public decimal RowId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal IncrementId { get; set; }

    public decimal? EmpSuperior { get; set; }

    public DateTime? ForDate { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0095Increment Increment { get; set; } = null!;
}
