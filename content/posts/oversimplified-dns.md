---
title: "Oversimplified DNS"
slug: "oversimplified-dns"
date: "2025-06-04T17:36:15.000Z"
author: "schemar"
lastmod: "2025-06-03T16:34:43.000Z"
description: "Our computers access a server via the server's IP address. Humans use domains instead. How do our browsers know the IP of a domain? The answer is DNS."
---

Our computers access servers on the internet via the servers' respective IP address. For convenience, however, we use domains as they are easier for us to remember. So how do our browsers know which IP to contact when we ask for a domain? The answer is the Domain Name System or, in short, DNS.

> This article oversimplifies DNS a lot. You can use it as a starting point when learning about DNS or you can use it as a reference to come back to when you are still learning about DNS. If you want to learn everything about DNS, you need to gather more detailed resources like RFCs [1034](https://tools.ietf.org/html/rfc1034), [1035](https://tools.ietf.org/html/rfc1035), or [2181](https://tools.ietf.org/html/rfc2181).

## Zones of Authority

Administrators manage domain names in _zones._ Each zone is managed by a _name server._ In the hierarchy of zones, a name server may delegate a part of the zone it manages to a different name server. In that case, the delegated part becomes its own zone (or _subzone_) that the different name server has _authority_ over. Thus, we end up with a tree of zones that each has its own authoritative name servers.

At the root of this tree is the _root zone_ which is managed by _root name servers._ They delegate authority for the _top-level domains_ to the authoritative name servers of these domains, e.g. `com` or `io`. Those name servers in turn delegate authority to the name servers of their subdomains, e.g. `level1.com`. The authoritative name server of `level1.com` could manage sub-domains of that domain or again delegate to other name servers further down the tree, e.g. `level2.level1.com`.

## Domain Name Resolution

Each leaf in the tree of domain names has a label. We separate labels with the period `.`. We label the root zone with an empty string. So the labels `level2`, `level1`, `com`, and `<empty string>` make up the _fully qualified domain name_`level2.level1.com.` (we usually don't write the trailing period and imply it instead).

When we access a resource on the internet, our computer doesn't know all the zones and their respective name servers of the entire internet. Instead, it is sufficient if it knows a root name server. Let us assume we want  to access `level2.level1.com`. In step one, our computer may ask a root name server for the IP of `level2.level1.com.`. The root name server will reply with the name server for `com.` that our computer may ask next. The name server of `com.` replies with yet another name server to ask for `level1.com.`. Finally, that name server responds with an `A` record for the requested domain and we can access it through that IP.

The above example explains an _iterative_ lookup. In a recursive lookup, on the other hand, our computer would only ask a single name server, e.g. a DNS in our local network, and that name server would in turn ask other name servers to finally return (and possibly cache) the `A` record for the requested domain.

## DNS Records

> There are different kinds of DNS records and we won't go over all of them here. See [RFC 1035](https://tools.ietf.org/html/rfc1035) for more details.

A DNS record is called a _resource record_ (or _RR_ in short). Let us discuss three kinds of records:

1. `A` records,
2. `NS` records, and
3. `SOA` records.

### A Records

An `A` record contains the IP address of a domain. It might look like this in the name server of `level1.com.`:

```dns
@          IN A     1.2.3.4
level2     IN A     5.6.7.8
level2     IN AAAA  2001:db4::1
```

The `@` character is a placeholder for the domain where this name server is authoritative. So in this case `level1.com.`.

`AAAA` is a so-called _quad-A_ record and specifies an IPv6, whereas `A` records specify an IPv4. It is listed only for reference and ignored in the further discussion.

In the above example, the records state that the IP of `level1.com` is `1.2.3.4` and the IP of `level2.level1.com` is `5.6.7.8`.

`IN` is the _zone class_ and stands for _internet._

### NS Records

An `NS` record contains the domain of an authoritative name server for the given domain. It might look like this in the name server of `level1.com.`:

```dns
level2b     IN NS    ns1.level2b.level1.com.
level2b     IN NS    ns2.level2b.level1.com.
```

The period at the end of the name servers' domain prevents the lookup at e.g. `ns1.level2b.level1.com.level1.com.`, which wouldn't make any sense (the domain of the `@` placeholder could be added to `ns1.level2b.level1.com` if it didn't have a trailing period).

The example above tells us that the authoritative name servers of the domain `level2b.level1.com.` are at `ns1.level2b.level1.com.` and `ns2.level2b.level1.com.`.

In this special case, we end up with a circular dependency. How can we know the IP of `level2b.level1.com.`, when the authoritative name server of that zone is under exactly the domain we want to look up? For these cases, we can use _glue records._ A glue record specifies the IP of the sub-name server as an `A` record in addition to the `NS` record:

```dns
ns1.level2b.level1.com. IN A     9.10.11.12
```

An example glue record of a DNS

### SOA Records

An `SOA` record identifies the _start of authority_ of a zone. It defines the name of the zone (can be the placeholder `@`), the single _primary name server_ for this zone, the email address of the administrator, and some more entries which we will not go over here. It could look something like this:

```dns
@ IN SOA ns1.level1.com. admin.level1.com. (... <left out> ...)
```

`ns1.level1.com.` is the primary name server and the email address of the administrator is `admin@level1.com` (if the email address contains periods, they must be escaped with a backslash, e.g. `sys\.admin.level1.com`).

### Zone File

If we combine the above examples to a zone file, it could look something like this:

```dns
@ IN SOA ns1.level1.com. admin.level1.com. (
        2018110201  ;Serial
        3600        ;Refresh
        1800        ;Retry
        604800      ;Expire
        86400       ;Minimum TTL
)

@           IN NS    ns1.level1.com.
@           IN NS    ns2.level1.com.

@           IN A     1.2.3.4
level2      IN A     5.6.7.8
level2      IN AAAA  2001:db4::1

level2b     IN NS    ns1.level2b.level1.com.
level2b     IN NS    ns2.level2b.level1.com.
ns1.level2b IN A     9.10.11.12
```

This is all you need to know to get started with and understand the basics of DNS.
