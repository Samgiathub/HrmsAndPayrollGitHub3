using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100EmpRoleAssign
{
    public int EmpRoleId { get; set; }

    public int? RoleId { get; set; }

    public int? EmpId { get; set; }
}
