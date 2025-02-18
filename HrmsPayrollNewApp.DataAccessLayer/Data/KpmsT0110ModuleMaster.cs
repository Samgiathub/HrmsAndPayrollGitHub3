using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class KpmsT0110ModuleMaster
{
    public int ModuleId { get; set; }

    public string? ModuleName { get; set; }

    public bool? IsActive { get; set; }

    public int? CreatedById { get; set; }

    public DateTime? CreatedDate { get; set; }

    public DateTime? ModifyDate { get; set; }

    public int? CmpId { get; set; }
}
