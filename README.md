# consul-docker-test

Terraform Modules and Examples to help with setting up test Consul clusters in Docker.

---

## Modules

There is a **server** module as well as a **client** module for configuring servers and clients within a datacenter respectively. The server module has two important outputs – `join` and `wan_join`. These can be used as `extra_args` to further invocations of these modules to cause other clients or servers to join the cluster properly.

## Examples

| Directory        | What it spins up                                                                                                                                                                                          |
|------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `simple-with-ui` | Runs a single 3‑server DC + 1 client agent with the UI enabled. 8500/8600 are mapped to the host so you can reach the UI & DNS locally.                                                                   |
| `multi-dc`       | Two datacenters (`primary`, `secondary`). Each DC has 3 servers and 1 UI‑enabled client. Primary UI/DNS is 8500/8600; secondary is 8501/8601. Uses three Docker networks (`primary`, `secondary`, `wan`). |
| `mesh-gateway`   | Starts from the multi‑dc example and layers on multiple mesh gateways. See its own [README](mesh-gateways/README.md) for details.                                                                         |

---

## Using Terraform Workspaces with the Makefile

Terraform workspaces let you keep **multiple, completely isolated state files** inside the same module folder. The included **Makefile** turns that into a lightweight environment switch so you can:

* run several Consul topologies side‑by‑side on the same laptop, or
* reuse the building‑block modules (`secure-base`, `secure-servers`, …) for many higher‑level examples without their states colliding.

### How the Makefile wires workspaces in

| Makefile piece         | Purpose                                                                                                                                                                                                                    |
|------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `WORKSPACE ?= default` | Sets a default workspace name that you can override from the CLI: `make … WORKSPACE=my‑lab`.                                                                                                                               |
| `workspace/%` target   | Runs `terraform workspace select -or-create=true` **inside the directory named by `%`** – creating/selecting the workspace *before* any other command runs.                                                                |
| Dependency macros      | If you **don’t** set `WORKSPACE`, each directory gets its **own** workspace (named after the directory). If you **do** set `WORKSPACE`, the same name is passed to every dependency so *all* modules share one state file. |
| Helper targets         | `init/%`, `apply/%`, `output/%`, `destroy/%` just run the matching Terraform command (`init`, `apply`, …) inside that directory **after** the workspace is ready.                                                          |

### Typical workflows

#### 1. Spin up the simple mesh once

```bash
# Builds secure‑base ➜ secure‑servers ➜ secure‑ui ➜ simple‑mesh
make simple-mesh/apply              # WORKSPACE defaults to each dir name
```

Workspaces created:

```
secure-base   secure-servers   secure-ui   simple-mesh
```

Each gets its own `.terraform/terraform.tfstate.d/<workspace>/terraform.tfstate`.

#### 2. Run the same example twice, side‑by‑side

```bash
# Environment A
make simple-mesh/apply WORKSPACE=demo-a

# Environment B
make simple-mesh/apply WORKSPACE=demo-b
```

Each directory now contains **two** independent state files (`demo-a`, `demo-b`). Container names & ports must still be unique, but Terraform state is isolated.

#### 3. Inspect outputs

```bash
make simple-mesh/output WORKSPACE=demo-a   # prints JSON outputs
```

#### 4. Tear everything down

```bash
make simple-mesh/destroy WORKSPACE=demo-a
```

### Quick reference for every directory in `TF_DIRS`

| Action                          | Command                                 |
|---------------------------------|-----------------------------------------|
| Create/select workspace only    | `make workspace/<dir> [WORKSPACE=name]` |
| Initialise providers & back‑end | `make <dir>/init [WORKSPACE=name]`      |
| Deploy                          | `make <dir>/apply [WORKSPACE=name]`     |
| Get outputs (JSON)              | `make <dir>/output [WORKSPACE=name]`    |
| Destroy                         | `make <dir>/destroy [WORKSPACE=name]`   |

### Tips & conventions

* **Separate vs shared workspaces** – Leave `WORKSPACE` unset to sandbox each module; set it to run a full topology inside a single state file.
* **Listing workspaces** – Inside any module directory, run `terraform workspace list` to see what the Makefile created.
* **Cleaning up empty workspaces** – After `destroy`, run `terraform workspace delete <name>` if you want to remove leftover directories.
* **Container port clashes** – Workspaces isolate state but not Docker resources. If you need multiple environments at once, adjust the `EXTERNAL_HTTP_PORT` / `EXTERNAL_DNS_PORT` variables (see each example’s `terraform.tfvars`).

---

### Working with upstream after the rename

Your fork’s history hasn’t changed—main is the same commits as master used to be—so syncing is simple:

```bash
# fetch new commits from upstream
git fetch upstream

# rebase your main on upstream/master
git rebase upstream/master

# push the updated history to your fork
git push
```

You can even set up a shortcut:

```bash
git branch --set-upstream-to=upstream/master main
# now `git pull --rebase` will track upstream by default
```

#### When you open a PR back to upstream
**_Base branch_**: mkeeler:master
**_Compare branch_**: natemollica-nm:main

GitHub has no problem with the different branch names.