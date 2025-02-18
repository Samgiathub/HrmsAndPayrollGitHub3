using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100EmpLtaMedicalDetail
{
    public decimal LmId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime? FromDate { get; set; }

    public DateTime? ToDate { get; set; }

    public string? Mode { get; set; }

    public decimal? Amount { get; set; }

    public int TypeId { get; set; }

    public int? CarryFwAmount { get; set; }

    public int? NoItClaims { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;
}
