using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0080GrievCommitteeMemberAllocation
{
    public int Gcmid { get; set; }

    public int? GcmempId { get; set; }

    public int? CmpId { get; set; }

    public int? MemberType { get; set; }

    public int? IsActive { get; set; }
}
