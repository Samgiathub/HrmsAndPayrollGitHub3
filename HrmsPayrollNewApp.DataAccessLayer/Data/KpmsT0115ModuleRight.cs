using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class KpmsT0115ModuleRight
{
    public int? CmpId { get; set; }

    public int ModuleRightsId { get; set; }

    public int? EmpRoleId { get; set; }

    public int? ModuleId { get; set; }

    public bool? IsActive { get; set; }

    public int? CreatedById { get; set; }

    public DateTime? CreatedDate { get; set; }

    public DateTime? ModifyDate { get; set; }
}
