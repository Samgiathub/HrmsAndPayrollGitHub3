using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0080EmpAuthMaster
{
    public int Id { get; set; }

    public int? EmpId { get; set; }

    public int? CmpId { get; set; }

    public string? LoginName { get; set; }

    public string? AuthType { get; set; }

    public string? SecurityStamp { get; set; }

    public string? RecoveryCodes { get; set; }

    public bool? IsEnable { get; set; }

    public DateTime? CreatedDate { get; set; }
}
