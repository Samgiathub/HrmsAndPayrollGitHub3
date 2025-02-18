using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class KpmsT0100EmpRoleAssign
{
    public int EmpRoleId { get; set; }

    public int? RoleId { get; set; }

    public int? EmpId { get; set; }

    public bool? IsActive { get; set; }

    public int? CmpId { get; set; }
}
