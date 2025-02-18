using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class KpmsT0120PageMaster
{
    public int PageId { get; set; }

    public string? PageName { get; set; }

    public bool? IsActive { get; set; }

    public int? CreatedById { get; set; }

    public DateTime? CreatedDate { get; set; }

    public DateTime? ModifyDate { get; set; }

    public int? ModuleId { get; set; }

    public int? CmpId { get; set; }
}
