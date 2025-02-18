using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050PrivilegeDetail
{
    public decimal TransId { get; set; }

    public decimal PrivilageId { get; set; }

    public decimal CmpId { get; set; }

    public decimal FormId { get; set; }

    public byte IsView { get; set; }

    public byte IsEdit { get; set; }

    public byte IsSave { get; set; }

    public byte IsDelete { get; set; }

    public byte IsPrint { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0020PrivilegeMaster Privilage { get; set; } = null!;
}
