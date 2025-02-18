using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0051SchemeDetailHistory
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal SchemeDetailId { get; set; }

    public decimal? OldAppEmpId { get; set; }

    public decimal? NewAppEmpId { get; set; }

    public DateTime? SystemDate { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
