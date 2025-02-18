using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class KpmsT0125PageRight
{
    public int? CmpId { get; set; }

    public int PageRightsId { get; set; }

    public int? EmpRoleId { get; set; }

    public int? ModuleId { get; set; }

    public int? PageId { get; set; }

    public bool? IsSave { get; set; }

    public bool? IsEdit { get; set; }

    public bool? IsDelete { get; set; }

    public bool? IsView { get; set; }

    public bool? IsActive { get; set; }

    public int? CreatedById { get; set; }

    public DateTime? CreatedDate { get; set; }

    public DateTime? ModifyDate { get; set; }
}
