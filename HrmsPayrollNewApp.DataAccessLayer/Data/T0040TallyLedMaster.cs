using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040TallyLedMaster
{
    public decimal TallyLedId { get; set; }

    public decimal CmpId { get; set; }

    public string TallyLedName { get; set; } = null!;

    public string? ParentTallyLedName { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0080EmpMaster> T0080EmpMasters { get; set; } = new List<T0080EmpMaster>();
}
