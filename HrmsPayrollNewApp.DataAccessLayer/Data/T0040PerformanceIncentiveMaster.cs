using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040PerformanceIncentiveMaster
{
    public decimal PerIncTranId { get; set; }

    public decimal CmpId { get; set; }

    public string PerName { get; set; } = null!;

    public string? PerDesc { get; set; }

    public decimal TotalPoints { get; set; }

    public string ApproveFrom { get; set; } = null!;

    public DateTime SysDate { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0100EmpPerformanceDetail> T0100EmpPerformanceDetails { get; set; } = new List<T0100EmpPerformanceDetail>();
}
